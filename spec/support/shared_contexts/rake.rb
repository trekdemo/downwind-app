require "rake"

RSpec.shared_context "rake" do
  let(:rake)      { Rake::Application.new }
  let(:task_name) { self.class.description }
  subject(:task)  { rake[task_name] }

  before do
    Rake.application = rake
    Rake.application.load_rakefile
  end
end
