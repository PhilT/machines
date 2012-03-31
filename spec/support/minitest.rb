# Standard minitest diff calls the OS's diff command. FakeFS breaks diff because
# diff is looking for the files on disk but the files are written by Tempfile
# while FakeFS is still active. The following modules provide a pure ruby diff
# and override MiniTest::Assertions::diff to utilitize it.

module Diff
  attr_accessor :diffs, :sequences

  def self.diffs(old, new)
    new, old, @diffs = new.lines.to_a, old.lines.to_a, []
    build_sequences(old, new)
    find_diffs(old, new, old.size, new.size)
  end

  private

  def self.find_diffs(old, new, row, col)
    if row > 0 && col > 0 && old[row-1] == new[col-1]
      find_diffs(old, new, row-1, col-1)
      @diffs << { :line => row, :change => :same, :string => old[row-1].strip }
    elsif col > 0 && (row == 0 || @sequences[row][col-1] >= @sequences[row-1][col])
      find_diffs(old, new, row, col-1)
      @diffs << { :line => col, :change => :add, :string => new[col-1].strip }
    elsif row > 0 && (col == 0 || @sequences[row][col-1] < @sequences[row-1][col])
      find_diffs(old, new, row-1, col)
      @diffs << { :line => row, :change => :delete, :string => old[row-1].strip }
    end
  end

  def self.build_sequences(old, new)
    rows, cols = old.size+1, new.size+1
    @sequences = rows.times.map{|x|[0]*(x+1)}
    rows.times.each do |row|
      cols.times.each do |col|
        @sequences[row][col] = if old[row-1] == new[col-1]
          @sequences[row-1][col-1] + 1
        else
          [@sequences[row][col-1].to_i, @sequences[row-1][col].to_i].max
        end
      end
    end
  end
end

module MiniTest
  module Assertions
    SYMBOLS = {:add => '+', :delete => '-', :same => ' '}

    def diff exp, act
      expect = mu_pp_for_diff exp
      butwas = mu_pp_for_diff act
      result = nil

      need_to_diff =
        (expect.include?("\n")    ||
         butwas.include?("\n")    ||
         expect.size > 30         ||
         butwas.size > 30         ||
         expect == butwas)

      return "Expected: #{mu_pp exp}\n  Actual: #{mu_pp act}" unless need_to_diff

      Diff.diffs(expect, butwas).map do |diff|
        SYMBOLS[diff[:change]] + diff[:string]
      end.join("\n")
    end
  end
end

