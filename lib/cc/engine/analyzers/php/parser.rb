require "cc/engine/analyzers/command_line_runner"
require "cc/engine/analyzers/parser_base"
require "cc/engine/analyzers/php/ast"
require "cc/engine/analyzers/php/nodes"

module CC
  module Engine
    module Analyzers
      module Php
        class Parser < ParserBase
          attr_reader :code, :filename, :syntax_tree

          def initialize(code, filename)
            @code = code
            @filename = filename
          end

          def parse
            runner = CommandLineRunner.new("php -d 'display_errors = Off' #{parser_path}")
            runner.run(code) do |output|
              json = parse_json(output)

              @syntax_tree = CC::Engine::Analyzers::Php::Nodes::Node.new(
                stmts: CC::Engine::Analyzers::Php::AST.json_to_ast(json, filename),
                node_type: "AST",
              )
            end

            self
          end

        private

          def parser_path
            relative_path = "../../../../../vendor/php-parser/parser.php"
            File.expand_path(
              File.join(File.dirname(__FILE__), relative_path),
            )
          end
        end
      end
    end
  end
end

