defmodule Makemore.Utils do
  def file_to_words(file) do
    path = Path.absname(file)
    lines = File.read!(path)
    String.split(lines,"\n")
  end
  def uniq_char(wordlist) do
    Enum.to_list(MapSet.new(String.codepoints(Enum.join(wordlist, ""))))
  end
  def stoi(chars) do
    Enum.reduce(chars, %{"." => 0}, fn x, acc ->
      Map.put(acc, x, map_size(acc))
    end)
  end
  def itos(chars) do
    Map.new(stoi(chars), fn {key, val} -> {val, key} end)
  end

end
