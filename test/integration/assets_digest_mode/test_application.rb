require 'integration_helper'

describe 'Render assets path with digest mode (Application)' do
  include Minitest::IsolationTest

  before do
    assets_directory.rmtree if assets_directory.exist?

    manifest = public_directory.join('assets.json')
    manifest.delete if manifest.exist?

    @current_dir = Dir.pwd
    Dir.chdir root

    @hanami_env = ENV['HANAMI_ENV']
    ENV['HANAMI_ENV'] = 'production'

    `bundle exec hanami assets precompile`
    public_directory.join('assets.json').must_be :exist?

    require root.join('config', 'environment')
    @app = StaticAssetsApp::Application.new
  end

  after do
    ENV['HANAMI_ENV'] = @hanami_env
    Dir.chdir @current_dir
    @current_dir = nil

    Dir["#{ public_directory }/**/*"].each do |f|
      next if ::File.directory?(f) || f.match(/(favicon\.ico|robots.txt)\z/)
      FileUtils.rm(f)
    end
  end

  let(:root)             { FIXTURES_ROOT.join('static_assets_app') }
  let(:public_directory) { root.join('public') }
  let(:assets_directory) { public_directory.join('assets') }

  it "renders with digest mode" do
    get '/'

    body = response.body
    body.must_include %(<link href="/assets/application-5ebdabab46f08c2cc8d56425bb34bc38.css" type="text/css" rel="stylesheet" integrity="sha256-VEro4QEXHHqDBtV8a9UG25qlAgrkuMWBSahU8LyTsoM=" crossorigin="anonymous">)
    body.must_include %(<link href="/assets/home-c229183232e6cfbf965a21ec0b06ee06.css" type="text/css" rel="stylesheet" integrity="sha256-3Ji7O2PJXQknS787XmhURSk7V55X6RH4gKESO6KkQXg=" crossorigin="anonymous">)
  end
end
