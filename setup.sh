# Set user password
echo "----------"
echo ""
echo "Which is the username?"
read userName

sudo passwd $userName

# Create Directories
mkdir /home/$userName/Projects
chmod $userName:$userName /home/aaronh/Projects

exit
