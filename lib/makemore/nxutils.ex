defmodule Makemore.Nxutils do
  @moduledoc """
  functions that can benefit from Nx native compilation for various backends
  see https://hexdocs.pm/nx/Nx.Defn.html
  """
  import Nx.Defn

  @doc """
  Takes a list of lists and converts it into an [[Nx]] tensor
  """
  defn tensor_f_list_of_lists(lol, dim_x, dim_y, type \\ :u16)  do # when is_list(lol) and is_integer(dim_x)  and is_integer(dim_y) do
    Nx.reshape(Nx.tensor(lol, type: type), {dim_x, dim_y}, names: [:rows, :cols])
  end
end
