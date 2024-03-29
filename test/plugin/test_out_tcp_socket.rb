require "helper"
require "fluent/plugin/out_tcp_socket.rb"

class TcpSocketOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::TcpSocketOutput).configure(conf)
  end
end
