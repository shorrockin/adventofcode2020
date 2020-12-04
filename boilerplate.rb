# typed: true
# frozen_string_literal: true
require 'sorbet-runtime'
require 'pry'

class String
  extend T::Sig

  sig {params(color_code: Integer).returns(String)}
  def colorize(color_code); "\e[#{color_code}m#{self}\e[0m"; end

  sig {returns(String)}; def black; colorize(30); end
  sig {returns(String)}; def red; colorize(31); end
  sig {returns(String)}; def green; colorize(32); end
  sig {returns(String)}; def yellow; colorize(33); end
  sig {returns(String)}; def blue; colorize(34); end
  sig {returns(String)}; def pink; colorize(35); end
  sig {returns(String)}; def teal; colorize(36); end
  sig {returns(String)}; def white; colorize(37); end
  sig {returns(String)}; def bold; colorize(1); end
  sig {returns(String)}; def dark; colorize(2); end
  sig {returns(String)}; def italic; colorize(3); end
  sig {returns(String)}; def underline; colorize(4); end
  sig {returns(String)}; def white_background; colorize(7); end
  sig {returns(String)}; def black_background; colorize(40); end
  sig {returns(String)}; def red_background; colorize(41); end
  sig {returns(String)}; def green_background; colorize(42); end
  sig {returns(String)}; def yellow_background; colorize(43); end
  sig {returns(String)}; def blue_background; colorize(44); end
  sig {returns(String)}; def pink_background; colorize(45); end
  sig {returns(String)}; def teal_background; colorize(46); end
end

module Symbols
  BLOCK = '█'
end

module AoC
  extend T::Sig

  sig {params(num: Integer, clear_screen: T::Boolean).void}
  def self.part(num, clear_screen: false)
    self.clear_screen if clear_screen
    puts "Part #{num}:".green
    puts "  #{'Solution'.green}: #{Assert.to_s(yield)}"
    puts ''
  end

  sig {void}
  def self.clear_screen
    Kernel.system "clear"
  end

  module IO
    extend T::Sig

    sig {params(strip: T::Boolean, strip_newline: T::Boolean).returns(T::Array[String])}
    def self.input_file(strip: true, strip_newline: true)
      return @input.dup unless @input.nil? # ARGV can only be used once

      if ARGV.empty?
        raise 'no input provided, please specify file as command line arg'
      end

      @input ||= $<.map(&:to_s)
      @input = if strip
        @input.map(&:strip)
      elsif strip_newline
        @input.map {|i| i.gsub("\n", '')}
      else
        @input
      end
      @input.dup # prevents alterations to source
    end

    sig {params(strip: T::Boolean, strip_newline: T::Boolean).returns(String)}
    def self.input_file_line(strip: true, strip_newline: true)
      T.must(input_file[0])
    end

    sig {returns(T.nilable(String))}
    def self.read_stdin_char
      begin
        # save previous state of stty
        old_state = `stty -g`
        # disable echoing and enable raw (not having to press enter)
        system 'stty raw -echo'
        c = T.must(STDIN.getc).chr
        # gather next two characters of special keys
        if c == "\e"
          extra_thread = Thread.new do
            c += T.must(STDIN.getc).chr
            c += T.must(STDIN.getc).chr
          end
          # wait just long enough for special keys to get swallowed
          extra_thread.join(0.00001)
          # kill thread so not-so-long special keys don't wait on getc
          extra_thread.kill
        end
      rescue => e
        puts "#{e.class}: #{e.message}"
        puts e.backtrace
      ensure
        # restore previous state of stty
        system "stty #{old_state}"
      end
      c
    end
  end

  class Logger
    extend T::Sig

    attr_accessor :logging
    attr_accessor :log_depth

    def initialize(logging: true)
      @logging = logging
      @log_depth = '  '
    end

    def log(str, *args)
      out = nil

      Kernel.puts "#{@log_depth}#{str} #{args.map(&:to_s).join(', ')}" unless @logging == false

      if Kernel.block_given?
        original_depth = @log_depth
        @log_depth += '  '
        begin
          out = yield
        ensure
          @log_depth = original_depth
        end
      end

      out
    end
  end
end

DefaultLogger = AoC::Logger.new

def log(str, *args)
  DefaultLogger.log(str, *args)
end

module Assert
  extend T::Sig
  include Kernel

  def self.to_s(val)
    value_str = val
    value_str = '"' + value_str + '"' if val.is_a?(String)
    value_str = 'nil' if val.nil?
    value_str
  end

  sig {params(expect: T.untyped, value: T.untyped, description: String).returns(T.untyped)}
  def self.equal(expect, value, description="")
    puts "  #{'✔'.green} #{description} == #{Assert.to_s(value)}" if value == expect
    puts "  #{'✖'.red} #{description}: expected #{Assert.to_s(expect)}, received #{Assert.to_s(value)}" if value != expect
    value
  end

  def self.call(target, expect, *args)
    T.unsafe(self).log_call(target, *args) {|m, r, desc| Assert.equal(expect, r, "#{m}(#{desc})")}
  end

  def self.log_call(target, method, *args)
    arg_description = T.must(args.to_s[1...-1])
    arg_description = '...' if arg_description.length > 60
    method, arg_description = method if method.is_a?(Array)

    result = target.send(method, *args)
    return yield method, result, arg_description if block_given?

    puts "  #{'-'.yellow} #{method}(#{arg_description}) == #{Assert.to_s(result)}"
  end
end
