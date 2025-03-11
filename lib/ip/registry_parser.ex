if Code.ensure_loaded?(Saxy) do
  defmodule IP.RegistryParser do
    @moduledoc """
    Simple parser for IANA special registry files using Saxy.
    """

    @doc """
    Parse a registry file from the priv directory.
    """
    @spec parse(String.t()) :: {:ok, [{String.t(), String.t()}]} | {:error, any}
    def parse(registry_name) do
      with {:ok, xml} <- read_file(registry_name <> ".xml"),
           {:ok, xml} <- Saxy.SimpleForm.parse_string(xml),
           :ok <- validate_registry(xml, registry_name),
           {:ok, xml} <- get_child_tag(xml, "registry"),
           {:ok, records} <- get_child_tags(xml, "record") do
        parse_records(records)
      end
    end

    @doc "Raising version of `parse/1`"
    @spec parse!(String.t()) :: [{String.t(), String.t()}] | no_return()
    def parse!(registry_name) do
      case parse(registry_name) do
        {:ok, result} -> result
        {:error, reason} when is_exception(reason) -> raise reason
        {:error, reason} -> raise RuntimeError, reason
      end
    end

    defp parse_records(records) do
      Enum.reduce_while(records, {:ok, []}, fn
        record, {:ok, records} ->
          with {:ok, address} <- get_child_tag(record, "address"),
               {:ok, address} <- get_text_content(address),
               {:ok, name} <- get_child_tag(record, "name"),
               {:ok, name} <- get_text_content(name),
               {:ok, global} <- get_child_tag(record, "global"),
               {:ok, global} <- get_text_content(global, allow_nil?: true),
               {:ok, reserved} <- get_child_tag(record, "reserved"),
               {:ok, reserved} <- get_text_content(reserved, allow_nil?: true) do
            description =
              [
                String.trim(name, "\""),
                if(global, do: "GLOBAL"),
                if(reserved, do: "RESERVED")
              ]
              |> Enum.reject(&is_nil/1)
              |> Enum.join(", ")

            addresses =
              address
              |> String.split(~r/\s*,\s*/)
              |> Enum.map(&{&1, description})

            {:cont, {:ok, records ++ addresses}}
          else
            error -> {:halt, error}
          end
      end)
    end

    defp validate_registry(xml, registry_name) do
      with :ok <- validate_tag(xml, "registry") do
        validate_attribute(xml, "id", registry_name)
      end
    end

    defp validate_tag({tag_name, _, _}, tag_name), do: :ok

    defp validate_tag({actual, _, _}, expected),
      do: {:error, "Expected `#{expected}` XML tag, but received `#{actual}`"}

    defp validate_attribute({tag, attributes, _}, key, value) do
      attributes
      |> Enum.find(&(elem(&1, 0) == key))
      |> case do
        nil ->
          {:error, "Tag `#{tag}` does not have an attribute named `#{key}`"}

        {_, actual} ->
          if actual == value do
            :ok
          else
            {:error,
             "Tag `#{tag}` has an attribute named `#{key}` but it's value is not correct. (`#{actual}` vs `#{value}`)"}
          end
      end
    end

    defp get_child_tag({_, _, content}, tag_name) do
      Enum.reduce_while(content, {:error, "Tag `#{tag_name}` not found"}, fn
        tag, _not_found when elem(tag, 0) == tag_name ->
          {:halt, {:ok, tag}}

        _, not_found ->
          {:cont, not_found}
      end)
    end

    defp get_child_tags({_, _, content}, tag_name) do
      tags =
        content
        |> Enum.filter(fn
          {^tag_name, _, _} -> true
          _ -> false
        end)

      {:ok, tags}
    end

    defp get_text_content(tag, opts \\ [])

    defp get_text_content({tag, _, content}, opts) do
      content
      |> Enum.filter(&is_binary/1)
      |> case do
        [] ->
          if opts[:allow_nil?] do
            {:ok, nil}
          else
            {:error, "Tag `#{tag}` does not contain any text content"}
          end

        content ->
          content =
            content
            |> Enum.join("")
            |> String.trim()

          {:ok, content}
      end
    end

    defp read_file(filename) do
      :ip
      |> :code.priv_dir()
      |> Path.join(filename)
      |> File.read()
    end
  end
end
