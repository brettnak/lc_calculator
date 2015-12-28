#!/usr/bin/env ruby

require 'trollop'

class InductanceCalculator
  attr_reader :frequency, :capacitance

  def initialize( frequency, capacitance )
    @frequency   = frequency   * (1000.0)
    @capacitance = capacitance * ( 1.0e-9 )
  end

  # f = 1.0 / ( 2pi * sqrt( LC ))
  # =>
  # L = 1.0 / ( C * (2.0 * pi * f) ^ 2 )
  def inductance
    return 1.0 / ( @capacitance * (2.0 * Math::PI * @frequency) ** 2.0 )
  end

  class CLI
    attr_reader :args

    def initialize( argv, instream = STDIN, errorstream = STDERR, outputstream = STDOUT )
      @args = gather_args( argv )
      @calculator = InductanceCalculator.new( @args[:capacitance], @args[:frequency] )
    end

    def gather_args( argv )
      parser = Trollop::Parser.new do
        opt :capacitance, "The capacitance of your LC circuit (in NanoFarads)",     :short => "-c", :type => :float
        opt :frequency,   "The desired frequency of your LC circuit (in KiloHertz", :short => "-f", :type => :float
        banner "Calculate the inductance needed for an LC oscillator"
      end

      return Trollop::with_standard_exception_handling( parser ) do
        raise Trollop::HelpNeeded if ARGV.empty?
        parser.parse( argv )
      end
    end

    def main
      puts @calculator.inductance
    end
  end
end

if __FILE__ == $0
  cli = InductanceCalculator::CLI.new( ARGV )
  cli.main
end
