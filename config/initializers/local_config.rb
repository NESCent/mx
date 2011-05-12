
# Set your local ip/server root here, if you are only running in test
# or development mode this doesn't need to be set
HOME_SERVER = 'foo.bar.com'
MAIL_SERVER = 'foo.bar.com'
HELP_WIKI = 'mx.phenomix.org'

# Supply the path to ImageMagik's 'identify' and 'convert' binaries
IMAGE_MAGICK_PATH = '/usr/local/bin/'

# For storing content files we use a symbolic link (public/files) that points to 
# a folder outside of the rails directory, so that it is
# not under version control, and is easier to back up, etc.
# 

FILE_PATH = "#{Rails.root.to_s}/public/files/"
WEB_PATH = "/files/"

TEMP_FILE_PATH = "#{FILE_PATH}temp/" # TODO: is this used? probably should be /tmp by default

IMAGE_FILE_PATH = "#{FILE_PATH}images/"
IMAGE_WEB_PATH = "#{WEB_PATH}images/"

# See the Chromatogram has_attachment when tweaking this, it should typically be left as is. 
CHROMATOGRAM_FILE_PATH = "#{FILE_PATH}chromatograms/"
CHROMATOGRAM_WEB_PATH = "#{WEB_PATH}chromatograms/"

GEL_IMAGE_FILE_PATH  = "#{FILE_PATH}gel_images/"
GEL_IMAGE_WEB_PATH = "#{WEB_PATH}gel_images/"

# for database backup/reload script (db/Rakefile)
DATA_DIR = "#{Rails.root.to_s}/db/dumps/"

# See http://paulschreiber.com/blog/2010/05/10/handling-rails-errors/
# ExceptionNotification::Notifier.exception_recipients = %w(my.name@mydomain.com)
# ExceptionNotification::Notifier.sender_address = %("Application Error" <app.error@mydomain.com>)
# ExceptionNotification::Notifier.email_prefix = "[Fancy App] "



# add your gmaps key here
GMAPS_KEY_PRODUCTION = 'get a key at the Google maps api site'
GMAPS_KEY_DEVELOPMENT = 'get ANOTHER key at the Google maps api site'

# Common words (excluded as an option in Ontology proofing/parsing
# TODO: deprecate or add as a install option for labels_refs
COMMON_WORDS = File.read("#{Rails.root.to_s}/config/authority_files/common_words.txt").split("\n").uniq!.sort

## Application Layout Constants ##
# tabs/subnav can be reconfigured here if you want to hide or rearange things

# TABS = ["otu", "chr", "mx", "content", "specimen", "seq", "ref", "association",  "taxon_name", "image", "ontology", "clave", "tag", "tree"]
# TAB_SUBNAV = YAML.load_file("#{Rails.root.to_s}/config/tabs.yaml")
# LAYOUT = YAML.load_file("#{Rails.root.to_s}/config/layout.yaml")


