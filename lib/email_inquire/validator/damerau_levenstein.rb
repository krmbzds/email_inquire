# frozen_string_literal: true

# Line-for-line C->Ruby conversion of:
# https://github.com/GlobalNamesArchitecture/damerau-levenshtein/blob/master/ext/damerau_levenshtein/damerau_levenshtein.c
# C-specific lines removed, and then tidied up with help from Rubocop

module DamerauLevenshtein
  def self.distance(s, t, block_size = 1, max_distance = 10) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Naming/UncommunicativeMethodParamName
    stop_execution = min = current_distance = pure_levenshtein = 0
    sl = s.length
    tl = t.length

    if block_size.zero?
      pure_levenshtein = 1
      block_size = 1
    end

    return tl if sl.zero?
    return sl if tl.zero?
    # case of lengths 1 must present or it will break further in the code
    return 1 if sl == 1 && tl == 1 && s[0] != t[0]

    sl += 1
    tl += 1

    # NOTE On Ruby conversion, init array values to zero, just to be sure (replicates malloc?)
    d = Array.new(sl * tl, 0)
    # populate 'vertical' row starting from the 2nd position (first one is filled already)
    (0..(tl - 1)).each do |i|
      d[i * sl] = i
    end

    # fill up array with scores
    (1..(sl - 1)).each do |i|
      d[i] = i
      break if stop_execution == 1

      current_distance = 10_000
      (1..(tl - 1)).each do |j|
        cost = 1
        cost = 0 if s[i - 1] == t[j - 1]

        half_sl = (sl - 1) / 2
        half_tl = (tl - 1) / 2

        block = block_size < half_sl || half_sl.zero? ? block_size : half_sl
        block = block < half_tl || half_tl.zero? ? block : half_tl

        while block >= 1
          swap1 = 1
          swap2 = 1
          i1 = i - (block * 2)
          j1 = j - (block * 2)
          (i1..(i1 + block - 1)).each do |k|
            if s[k] != t[k + block]
              swap1 = 0
              break
            end
          end
          (j1..(j1 + block - 1)).each do |k|
            if t[k] != s[k + block]
              swap2 = 0
              break
            end
          end

          del = d[j * sl + i - 1] + 1
          ins = d[(j - 1) * sl + i] + 1
          min = del
          min = ins if ins < min
          if pure_levenshtein.zero? && i >= 2 * block && j >= 2 * block && swap1 == 1 && swap2 == 1
            transp = d[(j - block * 2) * sl + i - block * 2] + cost + block - 1
            min = transp if transp < min
            block = 0
          elsif block == 1
            subs = d[(j - 1) * sl + i - 1] + cost
            min = subs if subs < min
          end
          block -= 1
        end
        d[j * sl + i] = min
        current_distance = d[j * sl + i] if current_distance > d[j * sl + i]
      end
      stop_execution = 1 if current_distance > max_distance
    end
    distance = d[sl * tl - 1]
    distance = current_distance if stop_execution == 1

    distance
  end
end
