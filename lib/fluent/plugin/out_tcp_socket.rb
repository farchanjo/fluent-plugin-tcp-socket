#
# Copyright 2019- TODO: Write your name
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/output"

module Fluent
  module Plugin
    class TcpSocketOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("tcp_socket", self)
      @@socket = nil
      config_param :hostname, :string, default: "localhost"
      config_param :port, :integer, default: 2238
      @@execution_thread = nil
      @@queue = Queue.new

      def start
         super
         log.info "TCP Plugin started with %s:%s" % [hostname, port]
         @@execution_thread = Thread.new { start_service_thread }
      end

      def stop
         if @@execution_thread != nil
            Thread.kill(@@execution_thread)
            log.info "TCP Plugin thread has been killed"
         end
         @@queue.close
         log.info "Queue is closed"
      end

      def process(tag, es)
         es.each do |time, record|
            @@queue.enq("%s\r\n" % [record])
         end
      end

      def start_service_thread
         log.info "TCP Plugin thread started for %s:%s" % [hostname, port]
         while record = @@queue.deq
            begin
              get_client.puts record
            rescue
              log.error "client error %s" %[$!]
              @@socket = nil
              @@queue.enq record
            end
         end
      end

      def get_client
         if @@socket == nil
            @@socket = TCPSocket.open(hostname, port)
            log.info "Socket established for %s:%s" % [hostname, port]
         end
         return @@socket
      end
    end
  end
end
