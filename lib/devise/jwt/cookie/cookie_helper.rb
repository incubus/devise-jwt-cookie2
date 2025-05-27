# frozen_string_literal: true

module Devise
  module JWT
    module Cookie
      # Helper class to build and remove cookies
      class CookieHelper
        include Cookie::Import['name', 'domain', 'secure', 'httponly', 'same_site']

        def build(token)
          if token.nil?
            remove_cookie
          else
            create_cookie(token)
          end
        end

        def read_from(cookies)
          cookies[name]
        end

        private

        def create_cookie(token)
          jwt = Warden::JWTAuth::TokenDecoder.new.call(token)
          res = {
            value: token,
            **global_options,
            expires: Time.at(jwt['exp'].to_i)
          }
          [name, res]
        end

        def remove_cookie
          res = {
            value: nil,
            **global_options,
            max_age: '0',
            expires: Time.at(0)
          }
          [name, res]
        end

        def global_options
          @global_options ||= {
            path: '/',
            httponly: httponly,
            secure: secure,
            same_site: same_site
          }.tap do |res|
            res[:domain] = domain if domain.present?
          end
        end
      end
    end
  end
end
