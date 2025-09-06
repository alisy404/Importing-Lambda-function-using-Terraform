# Here we are defining the output variables for the path module. This will allow us to reference the module's outputs in other parts of our configuration.
output "root" {
  value = path.root
}
# Here we are defining the output variables for the path module. This will allow us to reference the module's outputs in other parts of our configuration. 
output "module" {
  value = path.module
}


#These values will be used as reference in the module.tf file in the main directory.