#!/bin/bash

authors="$(git log --use-mailmap --author="@chromium.org" --format="format:%aE" | sort -u)"

syear="2018"
eyear="2021"
emonth="1"

asince="1/1/${syear}"
nauthors=""
for author in ${authors}; do
  count=$(git log --oneline --no-merges --use-mailmap --author="${author}" --since="${asince}" | wc | awk '{print $1}')
  if [[ ${count} -ne 0 ]]; then
    # echo "Found ${author} with ${count} commits since ${asince}"
    nauthors+="${author} "
  fi
done

echo -n "Author"
for year in $(seq ${syear} ${eyear}); do
  for month in $(seq 1 12); do
    since="${month}/1/${year}"
    echo -n ",${since}"
    if (( ${year} == ${eyear} && ${month} == ${emonth} )); then
      break
    fi
  done
done

echo

for author in ${nauthors}; do
  an="$(git log --oneline --no-merges --use-mailmap --author="${author}" --since="${asince}" --format="format:%aN" | sort -u)"
  echo -n "${an}"
  for year in $(seq ${syear} ${eyear}); do
    for month in $(seq 1 12); do
      since="--since=${month}/1/${year}"
      if (( ${month} == 12 )); then
        byear=$((year + 1))
        bmonth=1
      else
        bmonth=$((month + 1))
        byear=${year}
      fi
      before="--before=${bmonth}/1/${byear}"
      if (( ${year} == ${eyear} && ${month} == ${emonth} )); then
        before=""
      fi
      count="$(git log --oneline --no-merges --use-mailmap --author="${author}" ${since} ${before} | wc | awk '{print $1}')"
      echo -n ",${count}"
      if (( ${year} == ${eyear} && ${month} >= ${emonth} )); then
        break
      fi
    done
  done
  echo
done
