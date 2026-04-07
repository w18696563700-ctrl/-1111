#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'contracts_generation_lib'

ContractsGeneration.generate!

puts 'contracts_generate=passed'
puts "output_root=#{ContractsGeneration::EXPECTED_OUTPUT_ROOT}"
ContractsGeneration::EXPECTED_OUTPUTS.each do |path|
  puts "generated=#{path}"
end
