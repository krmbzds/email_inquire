# frozen_string_literal: true

require 'spec_helper'

# Stripped down version of https://github.com/GlobalNamesArchitecture/damerau-levenshtein/blob/master/spec/damerau-levenshtein_spec.rb
RSpec.describe DamerauLevenshtein do
  describe '.distance' do
    def read_test_file(file, fields_num) # rubocop:disable Metrics/MethodLength
      File.open(file, 'r') do |f|
        f.each_line do |line|
          fields = line.split('|')
          if line.match(/^\s*#/).nil? && fields.size == fields_num
            fields[-1] = fields[-1].split('#')[0].strip
            yield(fields)
          else
            yield(nil)
          end
        end
      end
    end

    it 'generates correct distance values' do
      tests = "#{File.dirname(__FILE__)}/data/damerau_levenshtein_test.txt"

      read_test_file(tests, 5) do |y|
        if y
          res = DamerauLevenshtein.distance(y[0], y[1], y[3].to_i, y[2].to_i)
          puts y if res != y[4].to_i
          expect(res).to eq y[4].to_i
        end
      end
    end

    it 'does not generate random negative distance' do
      100_000.times do
        distance = DamerauLevenshtein.distance('aaaa', 'aaaa', 1, 2)
        expect(distance).to(be >= 0)
      end
    end
  end
end
