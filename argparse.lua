local module = {}

local old_path = package.path
package.path = './src/?.lua;./libs/?/?.lua'

module.CmdParser = require 'cmd_parser'
module.Option = require 'option'
module.Option.keys = require 'opt_k'
module.Option.values = require 'opt_v'
module.validators = require 'validators'
module.Parser = require 'parser'

function module.new_parser(subcmds)
	return module.Parser:new(subcmds)
end

package.path = old_path

return module
