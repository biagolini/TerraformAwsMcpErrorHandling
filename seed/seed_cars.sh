#!/bin/bash
# Usage: export AWS_PROFILE=your-profile && ./seed_cars.sh

TABLE="mcp-error-handling-dev"
REGION="us-east-1"

put_car() {
  local id="$1" brand="$2" model="$3" year="$4" body_type="$5" \
        mileage="$6" price="$7" color="$8" description="$9" available="${10}"
  aws dynamodb put-item \
    --table-name "$TABLE" \
    --region "$REGION" \
    --item "{
      \"car_id\":{\"S\":\"$id\"},
      \"brand\":{\"S\":\"$brand\"},
      \"model\":{\"S\":\"$model\"},
      \"year\":{\"N\":\"$year\"},
      \"body_type\":{\"S\":\"$body_type\"},
      \"mileage\":{\"N\":\"$mileage\"},
      \"price\":{\"N\":\"$price\"},
      \"color\":{\"S\":\"$color\"},
      \"description\":{\"S\":\"$description\"},
      \"available\":{\"S\":\"$available\"}
    }" && echo "OK: $brand $model" || echo "FAIL: $brand $model"
}

echo "Seeding $TABLE..."

put_car "toyota_corolla_2020" "Toyota" "Corolla" "2020" "sedan" \
  "28000" "18500" "silver" \
  "Reliable commuter with Toyota Safety Sense and excellent fuel economy." "yes"

put_car "honda_civic_2019" "Honda" "Civic" "2019" "sedan" \
  "35000" "17800" "blue" \
  "Sporty and fuel-efficient with Honda Sensing suite and turbo engine." "yes"

put_car "ford_explorer_2020" "Ford" "Explorer" "2020" "suv" \
  "42000" "27500" "blue" \
  "Three-row SUV with EcoBoost engine, perfect for families." "yes"

put_car "toyota_rav4_2021" "Toyota" "RAV4" "2021" "suv" \
  "25000" "28500" "white" \
  "Compact SUV with AWD and Toyota Safety Sense 2.0. One owner." "yes"

put_car "honda_odyssey_2021" "Honda" "Odyssey" "2021" "minivan" \
  "35000" "32000" "white" \
  "Premium family hauler with leather seats and rear entertainment." "yes"

put_car "ford_f150_2019" "Ford" "F-150" "2019" "truck" \
  "52000" "29000" "gray" \
  "Best-selling truck with EcoBoost V6 and 13000 lbs towing capacity." "yes"

put_car "mazda3_hatch_2021" "Mazda" "Mazda3" "2021" "hatchback" \
  "22000" "22500" "red" \
  "Premium feel with Skyactiv technology and Bose audio." "yes"

put_car "ford_mustang_2019" "Ford" "Mustang" "2019" "coupe" \
  "32000" "27500" "red" \
  "EcoBoost with 310hp, performance package with upgraded brakes." "yes"

put_car "chevrolet_tahoe_2018" "Chevrolet" "Tahoe" "2018" "suv" \
  "58000" "29000" "white" \
  "Full-size SUV seating 8 with powerful V8 and massive cargo area." "yes"

put_car "toyota_camry_2017" "Toyota" "Camry" "2017" "sedan" \
  "68000" "13500" "gray" \
  "Dependable midsize sedan. Higher mileage but well maintained." "no"

echo "Done!"
