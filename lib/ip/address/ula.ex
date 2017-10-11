defmodule IP.Address.ULA do
  alias IP.Address
  alias IP.Prefix.EUI64
  use Bitwise

  @moduledoc false

  @doc """
  Generates an IPv6 Unique Local Address
  """
  @spec generate(binary, non_neg_integer, true | false) :: \
    {:ok, Address.ipv6} | {:error, term}
  def generate(mac, subnet_id, locally_assigned)
  when is_binary(mac)
   and is_integer(subnet_id) and subnet_id >= 0 and subnet_id <= 0xffff
   and is_boolean(locally_assigned)
  do
    with %DateTime{} = now <- DateTime.utc_now(),
         {:ok, ntp_time}   <- ntp_time(now),
         {:ok, eui}        <- EUI64.eui_portion(mac),
         {:ok, digest}     <- generate_digest(ntp_time, eui),
         {:ok, global_id}  <- last_40_bits_of_digest(digest),
         {:ok, prefix}     <- generate_address(locally_assigned,
                                               subnet_id,
                                               global_id)
    do
      {:ok, prefix}
    end
  end

  defp ntp_time(%DateTime{} = time) do
    seconds   = DateTime.to_unix(time)
    {msec, _} = time.microsecond
    {:ok, ((seconds + 0x83AA7E80) <<< 32) + msec}
  end

  defp generate_digest(ntp_time, eui) do
    with key    <- << ntp_time::unsigned-integer-size(64),
                      eui::unsigned-integer-size(64) >>,
         digest <- :crypto.hash(:sha, key),
         digest <- :binary.decode_unsigned(digest)
    do
      {:ok, digest}
    end
  end

  defp last_40_bits_of_digest(digest) do
    {:ok, digest &&& 0xffffffffff}
  end

  defp generate_address(locally_assigned, subnet_id, global_id) do
    address = (0xfc <<< 120) +
              (local_assignment_bit(locally_assigned) <<< 120) +
              (global_id <<< 80) +
              ((subnet_id &&& 0xffff) <<< 64)
    {:ok, address}
  end

  defp local_assignment_bit(true), do: 1
  defp local_assignment_bit(false), do: 0
end
