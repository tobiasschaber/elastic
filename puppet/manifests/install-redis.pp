#
#
# this file performs the installation of a
# redis node.
#
# author: Tobias Schaber (codecentric AG)
#
class installredis(

) {
	# start the installation of elasticsearch
	class { 'redis' :
                manage_repo => true,
	}
}

# trigger puppet execution
include installredis

