class BusinessSupportChecker::Criteria::Parser
  def self.parse(string)
    tokens = Lexer.tokenise(string)
    ast = AST.parse(tokens)
    Generator.generate(ast)
  end

  class Lexer
    def self.tokenise(string)
      scanner = StringScanner.new(string)
      tokens = []

      until scanner.eos?
        if scanner.scan(/\s+/)
          # ignore whitespace
        elsif scanner.scan(/\(/)
          tokens << { type: :open_parens }
        elsif scanner.scan(/\)/)
          tokens << { type: :close_parens }
        elsif scanner.scan(/AND|OR/)
          tokens << { type: :operator, value: scanner.matched }
        elsif scanner.scan(/[\w-]+/)
          tokens << { type: :identifier, value: scanner.matched }
        else
          raise "Unknown token."
        end
      end

      tokens
    end
  end

  class AST
    def initialize(tokens)
      @tokens = tokens
    end

    def parse
      read_expression
    end

    def self.parse(*args)
      new(*args).parse
    end

    private_class_method :new

  private

    attr_reader :tokens

    def ensure_token
      raise "Unexpected end" if tokens.empty?
    end

    def read_token(type)
      ensure_token

      token = tokens.shift
      raise "Unknown token: #{token}" unless token[:type] == type

      token
    end

    def is_token(type)
      tokens.first && tokens.first[:type] == type
    end

    def is_operator(value)
      is_token(:operator) && tokens.first[:value] == value
    end

    def read_expression
      lhs = read_operand_expression
      return lhs unless is_token(:operator)

      read_binary_expression(lhs)
    end

    def read_operand_expression
      ensure_token

      case tokens.first[:type]
      when :identifier
        read_token(:identifier)
      when :open_parens
        read_token(:open_parens)
        expr = read_expression
        read_token(:close_parens)
        expr
      else
        raise "Unknown operand: #{tokens.first}"
      end
    end

    def read_binary_expression(lhs)
      while is_token(:operator)
        op_token = read_token(:operator)
        operator = op_token[:value]
        operands = [lhs, read_operand_expression]

        while is_operator(operator)
          read_token(:operator)
          operands << read_operand_expression
        end

        lhs = { type: :operator, operator: operator, operands: operands }
      end

      lhs
    end
  end

  class Generator
    def initialize(ast)
      @ast = ast
    end

    def generate
      [generate_node(ast)]
    end

    def self.generate(*args)
      new(*args).generate
    end

    private_class_method :new

  private

    attr_reader :ast

    def generate_node(node)
      case node[:type]
      when :identifier
        generate_identifer(node)
      when :operator
        generate_operator(node)
      else
        raise "Unknown node: #{node}"
      end
    end

    def generate_identifer(node)
      node[:value]
    end

    OPERATOR_KEYS = {
      "AND" => "all_of",
      "OR" => "any_of",
    }.freeze

    def generate_operator(node)
      operands = node[:operands].map { |n| generate_node(n) }
      key = OPERATOR_KEYS.fetch(node[:operator])

      { key => operands }
    end
  end
end
