local module = {}

module.CmdParser = require 'argparse/cmd_parser'
module.Option = require 'argparse/option'
module.Option.keys = require 'argparse/opt_k'
module.Option.values = require 'argparse/opt_v'
module.validators = require 'argparse/validators'
module.Parser = require 'argparse/parser'

function module.new_parser(subcmds)
	return module.Parser:new(subcmds)
end

return module
