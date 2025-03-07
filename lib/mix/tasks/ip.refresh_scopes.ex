defmodule Mix.Tasks.Ip.RefreshScopes do
  @moduledoc """
  A mix task which downloads the latest special purpose address registries from
  the IANA website and stores them in this package's priv directory.
  """
  @shortdoc "Refresh IP scopes up to date"
  use Mix.Task

  @v4_file "iana-ipv4-special-registry.xml"
  @v6_file "iana-ipv6-special-registry.xml"
  @v4_url "https://www.iana.org/assignments/iana-ipv4-special-registry/iana-ipv4-special-registry.xml"
  @v6_url "https://www.iana.org/assignments/iana-ipv6-special-registry/iana-ipv6-special-registry.xml"

  @doc false
  @impl true
  def run(["--check"]) do
    v4_path = priv_path(@v4_file)
    v6_path = priv_path(@v6_file)

    if File.exists?(v4_path) && File.exists?(v6_path) do
      do_check(v4_path, v6_path)
    else
      Mix.shell().error("local registry copies do not exist")
      System.stop(1)
    end
  end

  def run([]) do
    Application.ensure_all_started(:req)

    v4_path = priv_path(@v4_file)
    v6_path = priv_path(@v6_file)

    with v4_task <- retrieve_v4(),
         v6_task <- retrieve_v6(),
         {:ok, v4_result} <- Task.await(v4_task),
         {:ok, v6_result} <- Task.await(v6_task),
         :ok <- File.write(v4_path, v4_result.body),
         :ok <- File.write(v6_path, v6_result.body) do
      Mix.shell().info("Registry files written")
      :ok
    else
      {:error, reason} -> handle_error(reason)
    end
  end

  def run(args) do
    Mix.shell().error("Unknown arguments: `#{inspect(args)}`")
    System.stop(1)
  end

  defp do_check(v4_path, v6_path) do
    Application.ensure_all_started(:req)

    with {:ok, v4_content} <- File.read(v4_path),
         {:ok, v6_content} <- File.read(v6_path),
         v4_task <- retrieve_v4(),
         v6_task <- retrieve_v6(),
         {:ok, v4_result} <- Task.await(v4_task),
         {:ok, v6_result} <- Task.await(v6_task) do
      if v4_result.body == v4_content && v6_content == v6_result.body do
        Mix.shell().info("registry data is up to date")
      else
        Mix.shell().error("registry data is out of date")
        System.stop(1)
      end
    else
      {:error, reason} -> handle_error(reason)
    end
  end

  defp retrieve_v4 do
    Task.async(fn ->
      Req.get(@v4_url)
    end)
  end

  defp retrieve_v6 do
    Task.async(fn ->
      Req.get(@v6_url)
    end)
  end

  defp priv_path(path) do
    :ip
    |> :code.priv_dir()
    |> Path.join(path)
  end

  defp handle_error(error) when is_exception(error) do
    error
    |> Exception.message()
    |> Mix.shell().error()
  end

  defp handle_error(error) when is_binary(error) do
    if String.printable?(error) do
      Mix.shell().error(error)
    else
      Mix.shell().error(inspect(error))
    end
  end

  defp handle_error(error), do: Mix.shell().error(inspect(error))
end
