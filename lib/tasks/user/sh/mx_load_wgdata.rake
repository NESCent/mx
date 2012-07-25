# encoding: UTF-8

require 'csv'

$USAGE = 'Call like: rake mx:load_wgdata RAILS_ENV=test'

# reads a csv file
# assumes taxon fields are first 5 fields - see @taxonsX vars below
# used for a one-off load of WG data

namespace :mx do
  desc $USAGE
  
    @charheaders = []
    @refheaders = []
    @otugroups = []
    @loginarray = [] # email split on @
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
    @login = nil
    @admin = nil
    @project = nil
    @matrix = nil
    @otugroup = nil
    @chargroup = nil
    
    # @file = 'vertebrates_v4_converted_NV-refined.csv'
    @file = 'bothplantfiles-refined-viaGoogle.csv'
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
    # @data_start = 'chromosome number (female)'
    # @data_end = 'molecular basis (dosage, Y dominant, W dominant, DM-W)'
    # @char_start = 'predicted ploidy (1n, 2n, 3n, 4n)'
    # @char_end = 'molecular basis (dosage, Y dominant, W dominant, DM-W)'
    @data_start = 'gametophytic chromosome number (minimum)'
    @data_end = 'molecular basis (dosage, Y dominant, W dominant, DM-W)'
    @char_start = 'Hybrid (no, yes)'
    @char_end = 'molecular basis (dosage, Y dominant, W dominant, DM-W)'
    @ref_start = 'source: ' + @data_start
    @ref_end = 'source: ' + @data_end
    @charFlag = 0
    @refFlag = 0
    @multirefFlag = 0
    @taxonFlag = 0
    @otuinfo = {}
    @multirefs = {}
    
  task :load_wgdata => [:environment] do

   

    if !@file
      puts "ERROR " + $USAGE
      abort # might be better way to do this
    end
    puts "getting the file"
    wgfile= CSV.read(@file, :headers => true, :encoding => 'windows-1251:utf-8')
    # wgfile= CSV.read(@file, :headers => true, :encoding => 'r:ISO8859-1')
# 
    # begin
     # ActiveRecord::Base.transaction do 




    # this section has to run first for empty DBs to add required base records
    # can probably turn off when importing to development DB, but the test and production DB will need these
    if !@taxons.has_key?('RootTest')
      #TODO: create project info @project
      #TODO: look for defaults for matrix, otugroup, and chargroup - create if doesn't exist
      @admin = Person.find_or_create_by_first_name(:first_name => 'Sandra', :last_name => 'Hall', :login => 'shall', :password => 'nescent!', :email => 'sandra.hall@nescent.org', :is_admin => 1, :creates_projects => 1)
      @admin.save
      puts "ADMIN ID: " + @admin.id.to_s
      #@admin = fetch_value("insert into people (first_name, last_name, login, password, is_admin,creates_projects, created_on, updated_on) values 
      #   ('Sandra', 'Hall', 'shall', sha1('footestbar'), 1,1, '#{@datetime}', '#{@datetime}');")
      @namespace = Namespace.find_or_create_by_name(:name => 'default', :short_name => 'default', :creator_id => @admin.id, :updator_id => @admin.id)
      @namespace.save!
      @project = Proj.find_or_create_by_name(:name => @project_name, :starting_tab => @starting_tab, :hidden_tabs => @hidden_tabs, :creator_id => @admin.id, :updator_id => @admin.id)
      if !@project.people.include?(@admin)
        @project.people << @admin
      end
      @project.save
      $proj_id = @project.id
      #puts "projectid: "+@project.id.to_s
      @matrix = Mx.find_or_create_by_name(:name => @matrix_name, :creator_id => @admin.id, :updator_id => @admin.id)
      @matrix.save
      @otugroup = OtuGroup.find_or_create_by_name(:name => @otugroup_name, :creator_id => @admin.id, :updator_id => @admin.id)
      @otugroup.save
      @chargroup = ChrGroup.find_or_create_by_name(:name => @chargroup_name, :creator_id => @admin.id, :updator_id => @admin.id)
      @chargroup.save
      @taxonroot = TaxonName.find(:name => 'RootTest')
      @taxonroot = TaxonName.create_new(:taxon_name => {:name => 'RootTest', :parent_id => @taxonid, :iczn_group => 'n/a', :creator_id => @admin.id, :updator_id => @admin.id}) unless @taxonroot      
      @taxonroot.save
      if !@taxonroot.projs.include?(@project)
        @taxonroot.projs << @project
      end
      @taxons['RootTest'] = @taxonroot.id
      @taxonid = @taxonroot.id
      #puts "@taxonid:  "+@taxonid.to_s+"   @taxonroot.id: "+@taxonroot.id.to_s
    end
    
    # generate headers for chars and refs, and create characters and states
    puts "generate headers"
    generate_headers
    @lineno = 1
    
    # for each row
    wgfile.each do |row|
      @lineno += 1
      puts "line number: #{@lineno}"
      # create the person record if needed [first_name last_name, login, password, email]
      #puts "generate person - " + row.to_s
      generate_person(row)
     
      # create the taxon names if needed
      #puts "generate_taxons"
      generate_taxons(row, @taxonid)
      
      # create the reference if needed   
      #puts "generate_refs"
      generate_refs(row)
           
      
      # create the otu add to otugroup and matrix
      #puts "generate_otus"
      generate_otus(row)
      
      
      # enter the codings with references 
      #puts "enter_codings"
      enter_codings(row)
      
      # enter notes/comments as tags? needed?
      #puts "enter_notes"
      #enter_notes(row)
      
      #TODO: add chargroup and otugroup to matrix
      
      @multirefs = {}
    end

    # @otugroups.each do |og|
      # puts "og name:   #{og.name}"
      # mx = Mx.find_by_name(og.name)
# 
      # mx.add_group(og)
    # end
      # end
    # rescue 
      # puts "FAIL."
    # end
   
   puts "DONE!"
  end # end task
  
  def generate_person(row = nil)
    @loginarray = row["entry email"].split('@')
    @login = @loginarray[0]
     if @login.length < 8
       @login = @login + "-login"
     end
    if !@people.has_key?(@login)
        @person = Person.find_or_create_by_email(:first_name => @loginarray[0] + "-first",
        :last_name => @loginarray[0] + "-last",
        :login => @login,
        :password => "nescent!",
        :email => row["entry email"])
        @person.save!
        @people[@login] = @person.id  
        if !@project.people.include?(@person)
          @project.people << @person
        end
      end
  end
  
  def generate_taxons(row = nil, taxonrootid = nil)
      @otuinfo["species"] = row[4]
      if !row[2].nil?
        @otuinfo["family"] = row[2].capitalize.strip 
      end
    # Higher taxonomic group, Order, Family, Genus, species
      # not doing row[0] now, these will go into vernacular table
      # if !@taxons1.has_key?(row[0].capitalize.strip)
        # iczn_group = "n/a"
        # parentid = taxonrootid
        # # puts [iczn_group, parentid, row[0]].join(", ")
        # # puts "taxonrootid: "+taxonrootid.to_s
        # #taxon = TaxonName.new(:name => row[0].capitalize, :parent_id => parentid, :iczn_group => iczn_group, :creator_id => @people[@login], :updator_id => @people[@login])
        # taxon = TaxonName.create_new(:taxon_name => {:name => row[0].capitalize.strip, :parent_id => parentid, :iczn_group => iczn_group, :creator_id => @people[@login], :updator_id => @people[@login]}, :person => @person)
        # taxon.save!
        # @taxons1[row[0].capitalize.strip] = taxon.id
      # end
      if !row[1].nil?
        @noOrderFlag = 0
          if !@taxons2.has_key?(row[1].capitalize.strip)
            iczn_group = "n/a"
            # parentid = @taxons1[row[0].capitalize.strip]
            parentid = taxonrootid
            taxon = TaxonName.create_new(:taxon_name => {:name => row[1].capitalize.strip, :parent_id => parentid, :iczn_group => iczn_group, :creator_id => @people[@login], :updator_id => @people[@login]}, :person => @person)
            taxon.save!
            @taxons2[row[1].capitalize.strip] = taxon.id
          end
      else
        @noOrderFlag = 1
        end
      if !@taxons3.has_key?(row[2].capitalize.strip)
        iczn_group = "family"
        if @noOrderFlag == 1
          parentid = taxonrootid
          @noOrderFlag = 0
        else
          parentid = @taxons2[row[1].capitalize.strip]
        end
        taxon = TaxonName.create_new(:taxon_name => {:name => row[2].capitalize.strip, :parent_id => parentid, :iczn_group => iczn_group, :creator_id => @people[@login], :updator_id => @people[@login]}, :person => @person)
        taxon.save!
        @taxons3[row[2].capitalize.strip] = taxon.id
        @matrix = Mx.find_or_create_by_name(:name => @otuinfo["family"] , :creator_id => @admin.id, :updator_id => @admin.id)
        @matrix.save
        if !@chargroup.mxes.include?(@matrix)
          @matrix.add_group(@chargroup)
        end
      end
      if !@taxons4.has_key?(row[3].capitalize.strip)
        iczn_group = "genus"
        parentid = @taxons3[row[2].capitalize.strip]
        taxon = TaxonName.create_new(:taxon_name => {:name => row[3].capitalize.strip, :parent_id => parentid, :iczn_group => iczn_group, :creator_id => @people[@login], :updator_id => @people[@login]}, :person => @person)
        taxon.save!
        @taxons4[row[3].capitalize.strip] = taxon.id
        @otuinfo["genus"] = row[3].capitalize.strip
      end
      if !@taxons5.has_key?(format_species(row[4]))
        iczn_group = "species"
        #puts "species"
        parentid = @taxons4[row[3].capitalize.strip]
        taxon = TaxonName.create_new(:taxon_name => {:name => format_species(row[4]), :parent_id => parentid, :iczn_group => iczn_group, :author => row["species author"], :creator_id => @people[@login], :updator_id => @people[@login]}, :person => @person)
        taxon.save!
        @taxons5[format_species(row[4])] = taxon.id
        @otuinfo["taxonid"] = taxon.id
      end
  end
  
  def format_species(sp_orig)
    #puts "format species"
    sn = sp_orig
    if sn.match("-")
      snarray = sn.split(/-/)
      sn = snarray[0]
    end
    if sn.match(" ")
      snarray = sn.split(" ")
      sn = snarray[0]
    end
    if sn.match(".2")
      sn = sn.gsub(".2", "")
    end
    if sn.match(".1")
      sn = sn.gsub(".1", "")
    end
    if sn.match(".")
      sn = sn.gsub(".", "")
    end
    if sn.match(/\*/)
      sn = sn.gsub(/\*/, "")
    end
    sn.downcase()
  end
  

  def generate_refs(row = nil)
    @refsh = {}
    ref = nil
    @multirefFlag = 0
    #puts "refheaders: " + @refheaders.to_s
    #puts @refsh.to_s
    @refheaders.each do |header|
    #puts "genref header: "+header
      position = 0
      reftxt = row[header]
      if !reftxt.nil?
        if reftxt.match("|;|")
          @multirefs = reftxt.split("|;|")
          @multirefFlag = 1
        else
          @multirefs << reftxt
        end
        @multirefs.each do |refstr|
          #puts "refstr: "+refstr.to_s
          position += 1
          if !refstr.match(/\|/)
            #puts "found a website"
            ref_author = "Anonymous"
            ref_year = nil
            ref_full = refstr
          else
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
            ref = Ref.find_or_create_by_full_citation_and_author_and_year(:author => ref_author, :year => ref_year, :full_citation => ref_full, :creator_id => @people[@login], :updator_id => @people[@login])
            ref.save
            if !@project.refs.include?(ref)
              @project.refs << ref  # make sure the ref is in this project as well
            end
          @refs[ref_full] = ref.id
          end
          @refsh["#{header}#{position.to_s}"] = @refs[ref_full]
        end
        #puts @refsh.to_s
      end
    end
  end
           

  def generate_otus(row)
    #puts "otuinfo: " + @otuinfo.to_s
    otuNotes = "notes: #{row["notes, comments"]}||infraspecific: #{row["infraspecific"]}||common name: #{row["common name"]}"
    @otu = Otu.new(:name => '', :taxon_name_id => @otuinfo["taxonid"], :notes => otuNotes, :creator_id => @people[@login], :updator_id => @people[@login])
    otuName = "#{@otuinfo["genus"]}_#{@otuinfo["species"].strip.gsub(" ","_")}"
    if !row["species author"].nil?
       otuName = "#{@otuinfo["genus"]}_#{@otuinfo["species"].strip.gsub(" ","_")}_#{row["species author"].strip.gsub(" ", "_")}"
    end
    @otu.name = otuName
    #puts "otu name:  #{@otu.name}"
    @otu.save
    puts "otu id:  #{@otu.id}"
    @otugroup.add_otu(@otu)
    @otugroupfam = OtuGroup.find_or_create_by_name(:name => @otuinfo["family"], :creator_id => @admin.id, :updator_id => @admin.id)
    @otugroupfam.save
    @otugroupfam.add_otu(@otu)
    if !@otugroups.include?(@otugroupfam)
      @otugroups << @otugroupfam
    end
    @otus[@otu.name] = @otu.id
    @otuinfo["id"] = @otu.id
    # puts "OTU Group - default:  #{@otugroup}"
    # puts "OTU Group - family:  #{@otugroupfam}"
    # puts "OTU Groups:  #{@otugroups}"
  end

  def enter_codings(row)
    #puts "refsh: "+@refsh.to_s
    values = []
    @charFlag = 0
    @charheaders.each do |header|
      position = 0
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
        @otu = Otu.find_by_id(@otuinfo["id"])
        #puts "charid: "+@char.id.to_s
        #puts "refid: "+refid.to_s
        #puts "otuid: "+@otu.id.to_s
        if @multirefFlag == 1
          values = row[header].split("|")
        else
          values << row[header].to_s
          #puts "am I here #{values} #{row[header]}"
        end
        values.each do |value|
          position += 1
          if @refsh.has_key?("source: #{header}#{position.to_s}")
            refid = @refsh["source: #{header}#{position.to_s}"]
          else
            refid = nil
          end
          #puts "refid: #{refid.to_s}"
          if @char.continuous?
            @coding = Coding.new(:chr_id => @char.id, :continuous_state => value, :ref_id => refid, :otu_id => @otu.id, :creator_id => @people[@login], :updator_id => @people[@login])
            @coding.save
          else
            @cstate = ChrState.find_by_name(value)
            if !@cstate.nil?
              @coding = Coding.new(:chr_id => @char.id, :chr_state_id => @cstate.id, :chr_state_state => @cstate.state, :chr_state_name => @cstate.name, :ref_id => refid, :otu_id => @otuinfo["id"], :creator_id => @people[@login], :updator_id => @people[@login])
              @coding.save
            else
            #Tag.create_new(:obj => @otu, :notes => [charname, value].join(" - ") )
            end
          end
        end
      end
    end
  end
  
 def generate_headers
    charinfo = nil
    wgfile2 = get_csv(@file)
    headers = wgfile2.shift
    # create the characters and states from header row add to chargroup
    #puts "generating headers"
    headers.each do |header|
      #puts "header: "+header
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
        #puts "charname: "+charname
        @charheaders << header
        @chr = Chr.find_or_create_by_name(:name => charname, :short_name => charname[0..5], :is_continuous => continuous, :creator_id => @admin.id, :updator_id => @admin.id)
        @chr.save
        if !@chargroup.chrs.include?(@chr)
          @chargroup.add_chr(@chr)
        end
        if @charFlag == 1
          charstates = charinfo[1].delete(')').split(',')
          st = 0
          charstates.each do |state|
            #puts "state: "+state.strip
            statename = state.strip
            @chrstate = ChrState.find_or_create_by_name_and_chr_id(:name => statename, :state => st.to_s, :chr_id => @chr.id, :creator_id => @admin.id, :updator_id => @admin.id)
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

