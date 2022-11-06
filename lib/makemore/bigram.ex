defmodule Makemore.Bigram do
  def create_tensor(file, ints \\ true) do
    words = Makemore.Utils.file_to_words(file)
    numchars = map_size(Makemore.Utils.stoi(Makemore.Utils.uniq_char(words)))
    # stoi = Makemore.Utils.stoi(chars)
    bm = if ints do bigram_map(words, true) else bigram_map(words) end
    sbm = sorted_desc(bm)
    {_, vallist}  = bgram_to_mat(sbm)
    btensor = Nx.tensor(vallist, type: :u16)
    Nx.reshape(btensor, {numchars, numchars}, names: [:rows, :cols])
  end


  def bgram_to_mat(bgram) do
    bgram_to_mat(bgram, [], [])
  end


  def bgram_to_mat(bgram, pos, vals) do
    case bgram do
      [] -> {pos, vals}
      _ ->
        [{{x, y}, val} | newbgram ] = bgram
        newpos = [{x, y} | pos]
        newvals = [val | vals]
        bgram_to_mat(newbgram, newpos, newvals)
      end
  end

  # ```
  # A bigram or digram is a sequence of two adjacent elements from a string of tokens,
  # which are typically letters, syllables, or words.
  # https://en.wikipedia.org/wiki/Bigram
  # e.g. given a word excalibur it will produce
  # a list that is a rolling window of two characters .. hence bigram
  # ex xc ca al li ib bu ur
  # to help denote the start of a word and end of a word this adds a "."
  # and after the word
  # so the result would be
  # bigrams_from_word("excalibur") -> [".e", "ex", "xc", "ca", "al", "li", "ib", "bu", "ur", "r."]
  # ```###
  def bigrams_from_word(word) when is_binary(word) do
    chs = String.graphemes("." <> word <> ".")
    Enum.zip(chs, ([_ | tail] = chs; tail))
  end


  def sorted_largest(bigram) do
    Enum.sort(Map.to_list(bigram), fn a, b ->
      {_, aval} = a
      {_, bval} = b
      aval >= bval
    end)
  end

  def sorted_asc(bigram) do
    Enum.sort(Map.to_list(bigram), fn a, b ->
      {{ax,ay}, _} = a
      {{bx,by}, _} = b
      {ax, ay} <= {bx, by}
    end)
  end


  def sorted_desc(bigram) do
    Enum.sort(Map.to_list(bigram), fn a, b ->
      {{ax,ay}, _} = a
      {{bx,by}, _} = b
      {ax, ay} >= {bx, by}
    end)
  end


  # takes a list of words and returns a (hash)map of all the bigrams
  # occuring in the list of words by the count of the number of occurences
  # of each bigram in the list of words
  # bigrams_from_word - see bigrams_from_word
  #
  def bigram_map(words, ints \\ true, pad \\ true) do
    chars = Makemore.Utils.uniq_char(words)
    stoi = Makemore.Utils.stoi(chars)

    bigrams_list =
      List.flatten(
        for w <- words do
          bigrams_from_word(w)
        end
      )

    char_bigrams =
      Enum.reduce(bigrams_list, %{}, fn bigram, acc ->
        exist = Map.get(acc, bigram)

        case exist do
          nil -> Map.put(acc, bigram, 1)
          _ -> Map.put(acc, bigram, exist + 1)
        end
      end)

    bigrams =
      if pad do
        # pad missing
        Enum.reduce(stoi, %{}, fn outer_tuple, acc ->
          {xchar, _} = outer_tuple
          acc2 = Enum.reduce(stoi, %{}, fn inner_tuple, inner_acc ->
            {ychar, _} = inner_tuple
            value = Map.get(char_bigrams, {xchar, ychar}, 0)
            Map.put(inner_acc, {xchar, ychar}, value)
          end)
          Map.merge(acc, acc2)
        end)
      else
        char_bigrams
      end

      bigrams_map =
      if ints do
        Enum.reduce(bigrams, %{}, fn bigram, acc ->
          {{xch, ych}, count} = bigram
          xint = stoi[xch]
          yint = stoi[ych]
          Map.put(acc, {xint, yint}, count)
        end)
      else
        bigrams
      end

    bigrams_map
  end


end
