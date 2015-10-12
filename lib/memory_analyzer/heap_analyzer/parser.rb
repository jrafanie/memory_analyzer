require 'json'
require 'ruby-progressbar'
require 'active_support/core_ext/hash/keys'

module MemoryAnalyzer
  class HeapAnalyzer
    module Parser
      def self.parse(file, show_progress = true)
        if show_progress
          parse_file_with_progress(file)
        else
          parse_file(file)
        end
      end

      private

      def self.parse_file_with_progress(file)
        progress = ProgressBar.create(
          :title         => "Parsing",
          :total         => `wc -l #{file}`.split.first.to_i,
          :format        => "%t: |%B| %e",
          :throttle_rate => 0.1
        )
        parse_file(file) { progress.increment }
          .tap { progress.finish }
      end

      def self.parse_file(file)
        File.open(file) do |f|
          f.each_line.collect do |l|
            yield if block_given? # For progress reporting
            clean_node(JSON.parse(l))
          end
        end
      end

      def self.clean_node(node)
        node.tap do |n|
          n.deep_symbolize_keys!
          n[:type] = n[:type].to_sym
          n[:references] = Array(n[:references]).uniq
        end
      end
    end
  end
end