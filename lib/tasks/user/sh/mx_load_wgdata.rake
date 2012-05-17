# encoding: UTF-8

require 'csv'

$USAGE = 'Call like: rake mx:load_wgdata RAILS_ENV=test'

# reads a csv file
# used for a one-off load of WG data

namespace :mx do
  desc $USAGE
  
    @charheaders = []
    @refheaders = []
    @otuinfo = {}
    @people = {}
    @taxons = {}
    @taxons1 = {} #  Higher taxonomic group
    @taxons2 = {} #  Order
    @taxons3 = {} #  Family 
    @taxons4 = {} #  Genus
    @taxons5 = {} #  species
    @refs = {}
    @refsh = {}
    @otus = {}
    @notes= {}
    @taxonid = nil
    @person = nil
    @admin = nil
    @project = nil
    @matrix = nil
    @otugroup = nil
    @chargroup = nil
    
    @file = 'converted.csv'
    @matrix_name = 'default'
    @otugroup_name = 'default'
    @chargroup_name = 'default'
    @project_name = 'Tree of Sex'
    @starting_tab = 'trait'
    @hidden_tabs = "---
 - associations
 - contents
 - measurements
 - seqs
 - images
 - trees
 "
    @taxon_start = 1
    @taxon_end = 5
    @data_start = 'chromosome number (female)'
    @data_end = 'molecular basis (dosage, Y dominant, W dominant)'
    @char_start = 'predicted ploidy (1n, 2n, 3n, 4n)'
    @char_end = 'molecular basis (dosage, Y dominant, W dominant)'
    @ref_start = 'source: ' + @data_start
    @ref_end = 'source: ' + @data_end
    @charFlag = 0
    @refFlag = 0
    @taxonFlag = 0
    @otuinfo = {}
    
  task :load_wgdata => [:environment] do

   

    if !@file
      puts "ERROR " + $USAGE
      abort # might be better way to do this
    end
    puts "getting the file"
    wgfile= CSV.read(@file, :headers => true, :encoding => 'windows-1251:utf-8')
# 
    # begin
     # ActiveRecord::Base.transaction do 




    # this section has to run first for empty DBs to add required base records
    # can probably turn off when importing to development DB, but the test and production DB will need these
    if !@taxons.has_key?('RootTest')
      #TODO: create project info @project
      #TODO: look for defaults for matrix, otugroup, and chargroup - create if doesn't exist
      @admin = Person.find_or_create_by_first_name(:first_name => 'Sandra', :last_name => 'Hall', :login => 'shall', :password => 'testtest', :email => 'sandra.hall@nescent.org', :is_admin => 1, :creates_projects => 1)
      @admin.save
      #@admin = fetch_value("insert into people (first_name, last_name, login, password, is_admin,creates_projects, created_on, updated_on) values 
      #   ('Sandra', 'Hall', 'shall', sha1('footestbar'), 1,1, '#{@datetime}', '#{@datetime}');")
      @namespace = Namespace.find_or_create_by_name(:name => 'default', :short_name => 'default', :creator_id => @admin.id, :updator_id => @admin.id)
      @namespace.save
      @project = Proj.find_or_create_by_name(:name => @project_name, :starting_tab => @starting_tab, :hidden_tabs => @hidden_tabs, :creator_id => @admin.id, :updator_id => @admin.id)
      @project.people << @admin
      @project.save!
      $proj_id = @project.id
      #puts "projectid: "+@project.id.to_s
      @matrix = Mx.find_or_create_by_name(:name => @matrix_name, :creator_id => @admin.id, :updator_id => @admin.id)
      @matrix.save
      @otugroup = OtuGroup.find_or_create_by_name(:name => @otugroup_name, :creator_id => @admin.id, :updator_id => @admin.id)
      @otugroup.save
      @chargroup = ChrGroup.find_or_create_by_name(:name => @chargroup_name, :creator_id => @admin.id, :updator_id => @admin.id)
      @chargroup.save
      @taxonroot = TaxonName.create_new(:taxon_name => {:name => 'RootTest', :parent_id => @taxonid, :iczn_group => 'n/a', :creator_id => @admin.id, :updator_id => @admin.id})        
      @taxonroot.save!
      @taxonroot.projs << @project
      @taxons['RootTest'] = @taxonroot.id
      @taxonid = @taxonroot.id
      puts "@taxonid:  "+@taxonid.to_s+"   @taxonroot.id: "+@taxonroot.id.to_s
    end
    
    # generate headers for chars and refs, and create characters and states
    puts "generate headers"
    generate_headers

    # for each row
    wgfile.each do |row|
      puts @otuinfo.to_s
      # create the person record if needed [first_name last_name, login, password, email]
      #puts "generate person - " + row.to_s
      generate_person(row)
     
      # create the taxon names if needed
      #puts "generate_taxons"
      generate_taxons(row, @taxonid)
      
      # create the reference if needed   
      #puts "generate_refs - " + row.to_s
      generate_refs(row)
           
      
      # create the otu add to otugroup and matrix
      #puts "generate_otus"
      generate_otus(row)
      
      
      # enter the codings with references  1:30
      #puts "enter_codings"
      enter_codings(row)
      
      # enter notes/comments as tags? needed?
      #puts "enter_notes"
      #enter_notes(row)
      
      #TODO: add chargroup and otugroup to matrix
      
    end


      # end
    # rescue 
      # puts "FAIL."
    # end
   
   puts "DONE!"
  end # end task
  
  def generate_person(row = nil)
    if !@people.has_key?(row["entry initials"])
        @person = Person.new(:first_name => row["entry initials"],
        :last_name => row["entry initials"],
        :login => row["entry initials"]+"-login",
        :password => "nescent!",
        :email => "sandra.hall@nescent.org")
        @person.save!
        @people[@person.last_name] = @person.id  
        @project.people << @person
      end
  end
  
  def generate_taxons(row = nil, taxonrootid = nil)
    # Higher taxonomic group, Order, Family, Genus, species
      if !@taxons1.has_key?(row[0].capitalize.strip)
        iczn_group = "n/a"
        parentid = taxonrootid
        # puts [iczn_group, parentid, row[0]].join(", ")
        # puts "taxonrootid: "+taxonrootid.to_s
        #taxon = TaxonName.new(:name => row[0].capitalize, :parent_id => parentid, :iczn_group => iczn_group, :creator_id => @people[row["entry initials"]], :updator_id => @people[row["entry initials"]])
        taxon = TaxonName.create_new(:taxon_name => {:name => row[0].capitalize.strip, :parent_id => parentid, :iczn_group => iczn_group, :creator_id => @people[row["entry initials"]], :updator_id => @people[row["entry initials"]]}, :person => @person)
        taxon.save!
        @taxons1[row[0].capitalize.strip] = taxon.id
      end
      if !@taxons2.has_key?(row[1].capitalize.strip)
        iczn_group = "n/a"
        parentid = @taxons1[row[0].capitalize.strip]
        taxon = TaxonName.create_new(:taxon_name => {:name => row[1].capitalize.strip, :parent_id => parentid, :iczn_group => iczn_group, :creator_id => @people[row["entry initials"]], :updator_id => @people[row["entry initials"]]}, :person => @person)
        taxon.save!
        @taxons2[row[1].capitalize.strip] = taxon.id
      end
      if !@taxons3.has_key?(row[2].capitalize.strip)
        iczn_group = "family"
        parentid = @taxons2[row[1].capitalize.strip]
        taxon = TaxonName.create_new(:taxon_name => {:name => row[2].capitalize.strip, :parent_id => parentid, :iczn_group => iczn_group, :creator_id => @people[row["entry initials"]], :updator_id => @people[row["entry initials"]]}, :person => @person)
        taxon.save!
        @taxons3[row[2].capitalize.strip] = taxon.id
      end
      if !@taxons4.has_key?(row[3].capitalize.strip)
        iczn_group = "genus"
        parentid = @taxons3[row[2].capitalize.strip]
        taxon = TaxonName.create_new(:taxon_name => {:name => row[3].capitalize.strip, :parent_id => parentid, :iczn_group => iczn_group, :creator_id => @people[row["entry initials"]], :updator_id => @people[row["entry initials"]]}, :person => @person)
        taxon.save!
        @taxons4[row[3].capitalize.strip] = taxon.id
        @otuinfo["genus"] = row[3].capitalize.strip
      end
      if !@taxons5.has_key?(row[4])
        iczn_group = "species"
        parentid = @taxons4[row[3].capitalize.strip]
        taxon = TaxonName.create_new(:taxon_name => {:name => format_species(row[4]), :parent_id => parentid, :iczn_group => iczn_group, :creator_id => @people[row["entry initials"]], :updator_id => @people[row["entry initials"]]}, :person => @person)
        taxon.save!
        @taxons5[row[4]] = taxon.id
        @otuinfo["species"] = row[4]
        @otuinfo["taxonid"] = taxon.id
      end
  end
  
  def format_species(sp_orig)
    sn = sp_orig.strip.gsub(" ", "")
    if sn.match("-")
      snarray = sn.split(/-/)
      sn = snarray[0]
    end
    if sn.match(".2")
      sn = sn.gsub(".2", "dottwo")
    end
    if sn.match(".1")
      sn = sn.gsub(".1", "dotone")
    end
    if sn.match(".")
      sn = sn.gsub(".", "")
    end
    if sn.match(/\*/)
      sn = sn.gsub(/\*/, "")
    end
    sn
  end
  

  def generate_refs(row = nil)
    @refsh = {}
    ref = nil
    puts "refheaders: " + @refheaders.to_s
    puts @refsh.to_s
    @refheaders.each do |header|
    #puts "genref header: "+header
      refstr = row[header]
      puts "header: " + header + "     refstr: "+refstr.to_s
      if !refstr.nil?
        if refstr.match("http:") || refstr.match(".com")
          #puts "found a website"
          ref_author = "Anonymous"
          ref_year = '2012'
          ref_full = refstr
        elsif refstr.match(/\|/)
          #puts "matched the pipe"
          refa = refstr.split("|")
          ref_author = [refa[0], refa[1]].join(", ")
          ref_year = refa[2]
          if refa.length == 3
            ref_full = refa.join(", ")
          else
            ref_full = refa[3]
          end
        end
        #puts "ref_full: "+ref_full
        if !@refs.has_key?(ref_full) && !ref_full.nil?
          ref = Ref.new(:author => ref_author, :year => ref_year, :full_citation => ref_full, :creator_id => @people[row["entry initials"]], :updator_id => @people[row["entry initials"]])
          if ref.save
            @project.refs << ref  # make sure the ref is in this project as well
          end
          @refs[ref_full] = ref.id
        end
        @refsh[header] = @refs[ref_full]
        puts @refsh.to_s
      end
    end
  end
           

  def generate_otus(row)
    @otu = Otu.new(:name => '', :taxon_name_id => @otuinfo["taxonid"], :notes => row["notes, comments"], :creator_id => @people[row["entry initials"]], :updator_id => @people[row["entry initials"]])
    @otu.name = @otuinfo["genus"]+"_"+@otuinfo["species"].strip.gsub(" ","_")
    @otu.save
    @otugroup.otus << @otu
    @otus[@otu.name] = @otu.id
    @otuinfo["id"] = @otu.id
  end

  def enter_codings(row)
    puts "refsh: "+@refsh.to_s
    @charFlag = 0
    @charheaders.each do |header|
      if header == @char_end
        @charFlag = 0
      end
      if header == @char_start
        @charFlag = 1
      end
      if !row[header].nil?
        charinfo = header.split('(')
        charname = charinfo[0].strip
        if @charFlag == 0
          charname = header
        end
        @char = Chr.find_by_name(charname)
        source = "source: "+header
        puts row[source]
        puts @refsh[source]
        @ref = Ref.find_by_id(@refsh[source])
        if @ref.nil?
          refid = nil
        else
          refid = @ref.id
        end
        @otu = Otu.find_by_id(@otuinfo["id"])
        puts "charid: "+@char.id.to_s
        puts "refid: "+refid.to_s
        puts "otuid: "+@otu.id.to_s
        value = row[header]
        if @char.continuous?
          @coding = Coding.new(:chr_id => @char.id, :continuous_state => value, :ref_id => refid, :otu_id => @otu.id, :creator_id => @people[row["entry initials"]], :updator_id => @people[row["entry initials"]])
          @coding.save
        else
          @cstate = ChrState.find_by_name(value)
          if !@cstate.nil?
            @coding = Coding.new(:chr_id => @char.id, :chr_state_id => @cstate.id, :chr_state_state => @cstate.state, :chr_state_name => @cstate.name, :ref_id => refid, :otu_id => @otuinfo["id"], :creator_id => @people[row["entry initials"]], :updator_id => @people[row["entry initials"]])
            @coding.save
          else
            #Tag.create_new(:obj => @otu, :notes => [charname, value].join(" - ") )
          end
        end
      end
    end
 

  end

  def enter_notes(row)

  end
  
 def generate_headers
    charinfo = nil
    wgfile2 = get_csv(@file)
    headers = wgfile2.shift
    # create the characters and states from header row add to chargroup
    #puts "generating headers"
    headers.each do |header|
      puts "header: "+header
      if header == @char_end
        @charFlag = 0
        @dataFlag = 0
      elsif header == @char_start
        @charFlag = 1
      elsif header == @data_start
        @dataFlag = 1
      end
      if @charFlag == 1
        charinfo = header.split('(')
        charname = charinfo[0].strip
        continuous = 0
      elsif @dataFlag == 1
        charname = header.strip
        continuous = 1
      end
      if @dataFlag == 1
        # puts "charname: "+charname
        @charheaders << header
        @chr = Chr.new(:name => charname, :short_name => charname[0..5], :is_continuous => continuous, :creator_id => @admin.id, :updator_id => @admin.id)
        @chr.save
        @chargroup.add_chr(@chr)
        if @charFlag == 1
          charstates = charinfo[1].delete(')').split(',')
          st = 0
          charstates.each do |state|
            #puts "state: "+state.strip
            statename = state.strip
            @chrstate = ChrState.new(:name => statename, :state => st.to_s, :chr_id => @chr.id, :creator_id => @admin.id, :updator_id => @admin.id)
            @chrstate.save
            st += 1
          end
        end
      end
        if header == @ref_end
          @refFlag = 0
        elsif header == @ref_start
          @refFlag = 1
        end
        if @refFlag == 1
          @refheaders << header
          #puts "@refheaders: "+@refheaders.to_s
        end
    end
  end

  
end # end namespace

