#coding:UTF-8
require 'uri'

module PukiwikiTextile
  def PukiwikiTextile.inlines str
    str.gsub!(/\[\[(.*)(?::|>)((?:https?|ftp|mailto):.*)\]\]/){|s|" \"#{$1}\":#{$2} "}
    str.gsub!(/(^.*)\'\'\'(.*?)\'\'\'/){"#{$1.length>0?"#{$1} ":""}_#{$2}_ "}
    str.gsub!(/(^.*)\'\'(.*?)\'\'/)    {"#{$1.length>0?"#{$1} ":""}*#{$2}* "}
    str.gsub!(/(^.*)%%(.*?)%%/)        {"#{$1.length>0?"#{$1} ":""}-#{$2}- "}
    return str
  end

  def PukiwikiTextile.convert source
    tt = ""
    arr = source.split(/\n/)
    str = arr.shift

    while str
      if str =~ /^\s+.+$/
        str.gsub(/^\s/,'')
        while a = arr.shift 
          if a =~ /^\s/
            str += a.gsub(/^\s/,'') + "\n"; next
          else
            break
          end
        end
        tt += "<pre>\n#{str}\n</pre>\n\n"
        str = a
      elsif str =~ /^\|/
        table = []
        str.gsub!(/^\|(.*)\|h$/){|s| s.gsub(/\|([^|]*)/,'|_. \1').gsub(/_\. h$/,"")}
        table.push(str.split('|')[1..-1])
        #str += "\n"
        while a = arr.shift
          if a =~ /^\|/
            a.gsub!(/^\|(.*)\|h$/){|s| s.gsub(/\|([^|]*)/,'|_. \1').gsub(/_\. h$/,"")}
            table.push(a.split('|')[1..-1])
            #str += a + "\n";
            next
          else
            break
          end
        end
        table.each_index do |i|
          tr = table[i]
          tr.each_index do |j|
            if tr[j] == '~'
              k = i-1
              while k >= 0
                if table[k][j] != '~'
                  s = table[k][j].match(/^([a-z0-9_\/\\]+\. )?(.*)/)
                  t = s[1]
                  u = s[2]
                  if t
                    if t =~ /(.*)\/([0-9]+)(.*)/
                      t = "#{$1}/#{$2.to_i+1}#{$3}"
                    end
                  else
                    t = '/2. '
                  end
                  table[k][j] = t+u
                  break
                end
                k -= 1
              end
            end
          end
        end
        tt += "\n"
        tt +=PukiwikiTextile.inlines(table.map{|e|"|#{e.delete_if{|f|f=='~'}.join('|')}|"}.join("\n")) +"\n"
        tt += "\n"
        str = a
      else
        str.gsub!(/^~(.*)$/,"\\1")
        str.gsub!(/(^>.*$)+/m){|s|".bq\n#{s.gsub(/^>/,'')}\n\n"}
        str.gsub!(/^(\*+)([^*].*)(?:\[#\w+\])/){|s|"\nh#{$1.length}. #{$2}\n"}
        str.gsub!(/^(\++)([^+].*)/){|s| "#{'#'*$1.length} #{$2}"}
        str.gsub!(/^(-+)([^\-].*)/){|s| "#{'*'*$1.length} #{$2}"}
        str.gsub!(/^:([^|]*)\|(.*)/){|s| "* #{$1} : #{$2}"}
        str.gsub!(/~$/,'')
        str = PukiwikiTextile.inlines(str)
        tt += str + "\n"
        str = arr.shift
      end
    end
    return tt
  end
end
