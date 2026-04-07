#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'contracts_generation_lib'

blocking_reasons = []

begin
  ContractsGeneration.load_truth
rescue StandardError => error
  blocking_reasons << error.message
end

begin
  ContractsGeneration.ensure_single_formal_entries!
rescue StandardError => error
  blocking_reasons << error.message
end

begin
  ContractsGeneration.ensure_expected_outputs_exist!
rescue StandardError => error
  blocking_reasons << error.message
end

begin
  ContractsGeneration.ensure_outputs_not_misplaced!
rescue StandardError => error
  blocking_reasons << error.message
end

before_snapshot = ContractsGeneration.snapshot_outputs

begin
  ContractsGeneration.generate!
rescue StandardError => error
  blocking_reasons << "regeneration failed: #{error.message}"
end

after_snapshot = ContractsGeneration.snapshot_outputs

if before_snapshot != after_snapshot
  blocking_reasons << 'dirty diff after regeneration'
end

unless File.file?(ContractsGeneration::MANIFEST_PATH) && ContractsGeneration.manifest_hash_valid?
  blocking_reasons << 'manifest hash mismatch'
end

if blocking_reasons.empty?
  puts 'contracts_check=passed'
  ContractsGeneration::EXPECTED_OUTPUTS.each do |path|
    puts "verified=#{path}"
  end
  exit 0
end

puts 'contracts_check=blocked'
blocking_reasons.each do |reason|
  puts "blocking_reason=#{reason}"
end
exit 1
