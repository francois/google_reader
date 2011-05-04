module GoogleReader
  autoload :Client, "google_reader/client"
  autoload :Source, "google_reader/source"
  autoload :Feed,   "google_reader/feed"
  autoload :Entry,  "google_reader/entry"

  GOOGLE_ATOM_NAMESPACE = "http://www.google.com/schemas/reader/atom/".freeze
end
