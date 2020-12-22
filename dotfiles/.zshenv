y_path=/apollo/env/envImprovement/var/lib/zsh/5.0.7/
if [[ -d $my_path && ${module_path[(I)$my_path]} -eq 0 ]]; then
  module_path[$(($#module_path+1))]=$my_path
fi
