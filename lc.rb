#!/usr/bin/env ruby

require 'trollop'

class LCFCalculator
  # Supply two of the three:
  # parameters - {}
  #  :frequency    - Float; in Kilo hertz
  #  :capacitance  - Float; in Nano Farads
  #  :inductance   - Float; in Micro Henries
  def initialize( parameters = {} )
    @frequency   = ( parameters[:frequency   ] || 0.0 ) * 1000.0
    @capacitance = ( parameters[:capacitance ] || 0.0 ) * 1.0e-9
    @inductance  = ( parameters[:inductance  ] || 0.0 ) * 1.0e-6
  end

  # f = 1.0 / ( 2pi * sqrt( LC ))
  # =>
  # L = 1.0 / ( C * (2.0 * pi * f) ^ 2 )
  def inductance
    return @inductance if @inductance

    return 1.0 / ( @capacitance * ( (2.0 * Math::PI * @frequency) ** 2.0 ) )
  end

  def capacitance
    return @capacitance unless @capacitance == 0.0

    return 1.0 / ( @inductance * ( (2.0 * Math::PI * @frequency) ** 2.0 ) )
  end

  def frequency
    return @frequency unless @frequency == 0.0

    return 1.0 / ( 2.0 * Math.pi * ( (@inductance * @capacitance) ** (0.5) ) )
  end

  class CLI
    attr_reader :args

    def initialize( argv, instream = STDIN, errorstream = STDERR, outputstream = STDOUT )
      @args = gather_args( argv )
      @calculator = LCFCalculator.new({
        :inductance  => @args[:inductance],
        :capacitance => @args[:capacitance],
        :frequency   => @args[:frequency],
      })
    end

    def gather_args( argv )
      parser = Trollop::Parser.new do
        opt :capacitance, "The capacitance of your LC circuit (in NanoFarads)",     :short => "-c", :type => :float
        opt :frequency,   "The desired frequency of your LC circuit (in KiloHertz", :short => "-f", :type => :float
        opt :inductance,  "The inductance of the LC circuit",                       :short => "-l", :type => :float
        banner "Calculate the inductance needed for an LC oscillator"
      end

      return Trollop::with_standard_exception_handling( parser ) do
        raise Trollop::HelpNeeded, "You must give at least 2 parameters" if ARGV.size < 2
        parser.parse( argv )
      end
    end

    def main
      puts "L-C Parameters:"
      puts "  %9.3f  uH"   % ( @calculator.inductance  * 1.0e6 )
      puts "  %9.3f  nF"   % ( @calculator.capacitance * 1.0e9 )
      puts "  %9.3f  k-HZ" %  ( @calculator.frequency  * 1.0e-3 )
    end
  end
end

if __FILE__ == $0
  cli = LCFCalculator::CLI.new( ARGV )
  cli.main
end
