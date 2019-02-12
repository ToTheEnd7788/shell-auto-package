#!/bin/sh

# # Get Sum
get_sum() {
  arr=$@
  sum=0
  for i in ${arr[*]}
  do
    sum=`echo $i $sum | awk '{print $1 + $2}'`
  done

  echo $sum
}

# # get max-tag
get_max_tag() {
  echo `git tag -l | grep -Eo "^v[0-9]+\.?[0-9]+" |
    grep -Eo "[0-9]+\.?[0-9]+$" |
    awk '{max=max>$0?max:$0}END{print max}'`
}

# # add tag and update version
fully_update() {
  max_tag=`get_max_tag`
  echo -e "\033[33m*** Please enter the tag name, or I will use max-tag-number( \033[31m v$max_tag \033[0m )\033[0m"
  read cur_max_tag

  if [ -z "$cur_max_tag" ]; then
    cur_max_tag=${cur_max_tag:-"v$max_tag"}
    else
      while [ `echo $cur_max_tag | grep -Ev "^v[0-9]+\.[0-9]+"` ]; do
        echo -e "\033[33m Your input is a invalid tag name, please try again(\033[31m v10.9 \033[0m)\033[0m"
        read cur_max_tag
      done
  fi

  echo -e "\033[33m*** Please input the commit info:\033[0m"
  read commit_info

  commit_info=${commit_info:-''}

  
}

# # struct target tar
struct_tar() {
  max_tag=`get_max_tag`
  echo -e "\033[33m*** Please tell me the folder name, or I will use default max-tag-number ( \033[31m$max_tag\033[0m ) \033[0m"
  read cur_max_tag

  while [ `echo $cur_max_tag | grep -Ev "(^v[0-9]+(\.[0-9]+)?)|(^[0-9]+(\.[0-9]+)?)"` ]; do
    echo -e "\033[33m Your input is a not available name, please try again(\033[31m 10.9 or v10.9 \033[0m)\033[0m"
    read cur_max_tag
  done

  cur_max_tag=${cur_max_tag:-"$max_tag"}

  if [ `echo "$cur_max_tag" | grep -Ev "^v"` ]; then
    cur_max_tag="v$cur_max_tag"
  fi

  mkdir $cur_max_tag &&
  cp -r $pathValue ${cur_max_tag}"/static" &&
  mv ${cur_max_tag}"/static/liquids" ${cur_max_tag}"/Views" &&
  tar -zcf ${cur_max_tag}".tar.gz" $cur_max_tag &&
  rm -r $cur_max_tag

  if [ $? == 0 ]; then
    echo -e "
    \033[32m>>> Package successfully! \033[0m"
  fi
}

# # 1. Delete the static folder if it is exsisted
pathValue="./apps/qmas/static"
echo -e "
\033[32m>>>>>> DELETE FOLDER: \033[0m
\033[33m*** Please input target relative path (\033[0m \033[31m./apps/qmas/static\033[0m \033[33m) ↓\033[0m"

read pathValue

pathValue=${pathValue:-'./apps/qmas/static'}

if [ -d $pathValue ]; then
  rm -r $pathValue
  if [ $? -eq 0 ]; then
    echo -e "\033[32m    >>> Delete target folder successfully\033[0m"
  else
    echo -e "\033[31m    >>> Failed to delete target folder \033[0m"
  fi
else
  echo -e "\033[32m    >>> The target folder isn't exist, you don't need to delete it \033[0m"
fi

sleep 0.9
echo -e "\033[32m\n>>>>>> PACKAGING CODES:\033[0m"

echo -e "\033[33mBuilding dll sources...\033[0m"
yarn b-qa-dll-p > temp

out_size_array=(`cat temp | grep "\[emitted\]" | awk '{print $2}' | grep -Eo "[0-9]+\.?[0-9]+$"`)
sizes=`get_sum ${out_size_array[*]}`

echo -e "\033[32m\n    >>> Building dll successfully:\033[0m
\033[36m        Total: ${#out_size_array[*]}  Sizes: $sizes KB\n\033[0m"

echo -e "\033[33mBuilding pages codes...\033[0m"
yarn b-qa-p > temp

out_size_array=(`cat temp | grep "\[emitted\]" | awk '{print $2}' | grep -Eo "[0-9]+\.?[0-9]+$"`)
sizes=`get_sum ${out_size_array[*]}`

echo -e "\033[32m\n    >>> Building dll successfully:\033[0m
\033[36m        Total: ${#out_size_array[*]}  Sizes: $sizes KB\n\033[0m"

rm temp

echo -e "\033[33m***Continue to add a tag or not(\033[0m\033[31m y/n \033[0m) ↓\033[0m"
read addtags

if [ "$addtags" = "n" ]; then
  struct_tar
elif [ "$addtags" = "y" ]; then
  fully_update
fi

exit 0