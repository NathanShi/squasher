require 'spec_helper'
require 'tempfile'

describe Squasher::Cleaner do
  let(:expected_file) { File.join(fake_root, 'db', 'migrate', '20140102030405_squasher_clean.rb') }

  before do
    Time.stub(:now => Time.new(2014, 1, 2, 3, 4, 5))
    Squasher.stub(:rake).with("db:migrate", :db_cleaning)
  end

  after do
    FileUtils.rm(expected_file)
  end

  it 'create a new migration' do
    Squasher::Cleaner.any_instance.stub(:prev_migration => nil)
    Squasher.clean

    expect(clean_migrations).to include(expected_file)
    File.open(expected_file) do |stream|
      content = stream.read
      expect(content).to include("SquasherClean")
    end
  end

  it 'update an existing migration' do
    Squasher.clean

    expect(clean_migrations.size).to be(1)
    expect(clean_migrations.first).to eq(expected_file)

    FileUtils.touch(File.join(fake_root, 'db/migrate/20140101010101_squasher_clean.rb'))
  end

  def clean_migrations
    Dir.glob(File.join(fake_root, '**/*_squasher_clean.rb'))
  end
end
