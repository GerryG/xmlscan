#
# xmlscan/version.rb
#
#   Copyright (C) UENO Katsuhiro 2002,2003
#
# $Id: version.rb,v 1.8.2.3 2003/05/01 15:50:00 katsu Exp $
#

module XMLScan

  # The version like 'X.X.0' (TENNY is 0) means that this is an unstable
  # release. Incompatible changes will be applied to this version
  # without special notice. This version should be distributed as a
  # snapshot only.
  #
  # TENNY which is larger than 1 (e.g. 'X.X.1' or 'X.X.2') means this
  # release is a stable release.

  VERSION = '0.2.3'
  RELEASE_DATE = '2003-05-02'

end
