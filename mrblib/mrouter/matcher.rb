module Mrouter
  class Matcher
    def initialize trie
      @trie = trie
    end

    def match path
      match_path @trie, path, {}
    end

    def match_path node, path, params
      if node.static?
        if start_with?(path, node.value)
          rest = path[node.value.size..-1]
        else
          return false
        end
      elsif node.dynamic?
        current_index = 0
        value = ''
        while current_index < path.size
          case path[current_index]
          when '/', '?', '.'
            break
          else
            value += path[current_index]
          end
          current_index += 1
        end
        rest = path[current_index..-1]
        params = params.merge(node.value.to_sym => value)
      end

      if (rest == '' || rest == '/') && !node.tag.nil?
        return params.merge(tag: node.tag)
      else
        if node.children.empty?
          false
        else
          node.children.map{|child| match_path child, rest, params }.find{|x| x}
        end
      end
    end

    def start_with? origin, target
      origin[0...target.length] == target
    end
  end
end