# -*- coding: utf-8 -*
require_relative '../lib/module_main'

describe "check_parameters?" do
  it "should return true if ARGV is empty" do
    stub_const("ARGV", [])
    Main::check_parameters?.should == true
  end
  
  it "should return false if ARGV is not empty" do
    stub_const("ARGV", ["słowik", "-t", "36", "-d"])
    Main::check_parameters?.should == false
  end
end

describe "parse_parameters" do
  it "should return Hash for parameters słowik -t 36" do
    stub_const("ARGV", ["słowik", "-t", "36"])
    opts = Main::parse_parameters
    {:help=>nil, :time=>"36", :dict=>nil}.should == opts.to_hash
  end

  it "should return Hash for parameters słowik" do
    stub_const("ARGV", ["słowik"])
    opts = Main::parse_parameters
    {:help=>nil, :time=>nil, :dict=>nil}.should == opts.to_hash
  end
end


describe "get_translations" do
  # it "should return results from wiktionary and dictpl for word 'słowik'" do
  #   stub_const("ARGV", ["-w", "słowik"])
  #   opts = Main::parse_parameters
  #   Main::get_translations(opts).should == {"wiktionary"=>{}, "dictpl"=>{"słowik"=>["nightingale"], "słowik białobrewy; Luscinia indicus; Tarsiger indicus (gatunek ptaka)"=>["white-browed bush-robin"], "słowik białosterny; Luscinia pectoralis (gatunek ptaka)"=>["Himalayan rubythroat", "white-tailed rubythroat"], "słowik chiński; pekińczyk żółty; Leiothrix lutea"=>["Pekin robin", "red-billed leiothrix"], "słowik chiński; pekińczyk żółty; pekińczyk koralodzioby; Leiothrix lutea"=>["Peking robin"], "słowik czarnogardły; Luscinia obscura"=>["black-throated blue robin"], "słowik himalajski; Luscinia brunnea (gatunek ptaka)"=>["Indian blue chat", "Indian blue robin"], "słowik modry; Luscinia cyane"=>["Siberian blue robin"], "słowik obrożny; Luscinia johnstoniae; Tarsiger johnstoniae (gatunek ptaka)"=>["collared bush-robin"]}}
  # end

  it "should return timeout message for word słowik and -t 5" do
    stub_const("ARGV", ["słowik","-t","5"])
    opts = Main.parse_parameters
    Dict.should_receive(:get_all_dictionaries_translations).
      and_return { sleep 20 }
    Main.get_translations(opts, "słowik").should == "Timeout for the query."
  end

  it "should go wrong if first word after name of program is '-h' " do
    stub_const("ARGV",["-h"])
    opts = Main.parse_parameters
    Main.get_translations(opts, ARGV[0]).should_not == "Timeout for the query."
  end
end
