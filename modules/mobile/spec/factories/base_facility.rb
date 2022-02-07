# frozen_string_literal: true

FactoryBot.define do
  factory :facility_442, class: 'BaseFacility' do
    unique_id {"442"}
    name {"Cheyenne VA Medical Center"}
    facility_type {"va_health_facility"}
    classification {"VA Medical Center (VAMC)"}
    website {"https://www.benefits.va.gov/cheyenne"}
    lat {41.14572808}
    long {-104.7895939}
    address {{"mailing"=>{}, "physical"=>{"zip"=>"82001-5356", "city"=>"Cheyenne", "state"=>"WY", "address_1"=>"2360 East Pershing Boulevard", "address_2"=>nil, "address_3"=>nil}}}
    phone {{"fax" => "307-778-7381",
            "main" => "307-778-7550",
            "pharmacy" => "866-420-6337",
            "after_hours" => "307-778-7550",
            "patient_advocate" => "307-778-7550 x7517",
            "mental_health_clinic" => "307-778-7349",
            "enrollment_coordinator" => "307-778-7550 x7579"}}
    hours {{"friday"=>"24/7", "monday"=>"24/7", "sunday"=>"24/7", "tuesday"=>"24/7", "saturday"=>"24/7", "thursday"=>"24/7", "wednesday"=>"24/7"}}
    services {{
      "benefits": {
        "other": "VETERANS SERVICE CENTER AND PUBLIC CONTACT TEAM, LOAN GUARANTY, VOCATIONAL REHABILITATION AND EMPLOYMENT ON SITE AT CHEYENNE VAMC",
        "standard": [
          "ApplyingForBenefits",
          "BurialClaimAssistance",
          "DisabilityClaimAssistance",
          "eBenefitsRegistrationAssistance",
          "HomelessAssistance",
          "UpdatingDirectDepositInformation",
          "VocationalRehabilitationAndEmploymentAssistance"
        ]
      }
    }}
    feedback {nil}
    access {nil}
    fingerprint {"0b72e1cecb422b245138f55033f361c6e1f18b18e4a8d5c857"}
    created_at {"2019-09-25T19:28:48.717Z"}
    updated_at {"2020-09-08T00:07:19.881Z"}
    location {"POINT (-104.78959389999994 41.145728080000026)"}
    mobile {nil}
    active_status {nil}
    visn {nil}
  end

  factory :facility_442GC, class: 'BaseFacility' do
    unique_id {"442GC"}
    name {"Fort Collins VA Clinic"}
    facility_type {"va_health_facility"}
    classification {"Multi-Specialty CBOC"}
    website {"https://www.cheyenne.va.gov/locations/Fort_Collins_VA_CBOC.asp"}
    lat {40.5538740000001}
    long {-105.087951}
    address {{
      "mailing": {},
        "physical": {
        "zip": "80526-8108",
        "city": "Fort Collins",
        "state": "CO",
        "address_1": "2509 Research Boulevard",
        "address_2": "",
        "address_3": null
      }
    }}
    phone {{
      "fax": "970-407-7440",
      "main": "970-224-1550",
      "pharmacy": "866-420-6337",
      "after_hours": "307-778-7550",
      "patient_advocate": "307-778-7550 x7517",
      "mental_health_clinic": "307-778-7349",
      "enrollment_coordinator": "307-778-7550 x7579"
    }}
    hours {{
      "Friday": "730AM-445PM",
      "Monday": "730AM-445PM",
      "Sunday": "Closed",
      "Tuesday": "730AM-445PM",
      "Saturday": "Closed",
      "Thursday": "730AM-445PM",
      "Wednesday": "730AM-445PM"
    }}
    services {{
      "other": [],
      "health": [
        {
          "sl1": [
            "PrimaryCare"
          ],
          "sl2": []
        },
        {
          "sl1": [
            "MentalHealthCare"
          ],
          "sl2": []
        },
        {
          "sl1": [
            "Audiology"
          ],
          "sl2": []
        },
        {
          "sl1": [
            "Dermatology"
          ],
          "sl2": []
        },
        {
          "sl1": [
            "Orthopedics"
          ],
          "sl2": []
        },
        {
          "sl1": [
            "SpecialtyCare"
          ],
          "sl2": []
        }
      ],
      "last_updated": "2020-08-31"
    }}
    feedback {{
      "health": {
        "effective_date": "2020-04-16",
        "primary_care_urgent": 0.48,
        "primary_care_routine": 0.79
      }
    }}
    access {{
      "health": {
        "audiology": {
          "new": 16.829268,
          "established": 7.747368
        },
        "dermatology": {
          "new": 6,
          "established": null
        },
        "orthopedics": {
          "new": 22,
          "established": 10
        },
        "primary_care": {
          "new": 15.117647,
          "established": 10.867924
        },
        "effective_date": "2020-08-31",
        "specialty_care": {
          "new": 17.295454,
          "established": 7.735714
        },
        "mental_health_care": {
          "new": 5,
          "established": 3.291666
        }
      }
    }}
    fingerprint {"ebde2c4b3458dbd2692fa68eae2c55d4c0a1e2069afa7fc0a104a05c1d58a9c9"}
    created_at {"2019-09-25T19:28:38.810Z"}
    updated_at {"2020-09-05T08:50:19.624Z"}
    location {"POINT (-105.08795099999998 40.553874000000064)"}
    mobile {false}
    active_status {"A"}
    visn {"19"}
  end
end
