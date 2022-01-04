# frozen_string_literal: true

require 'pdf_fill/hash_converter'
require 'pdf_fill/forms/form_base'
require 'string_helpers'

module PdfFill
  module Forms
    # rubocop:disable Metrics/ClassLength
    class Va21526ez < FormBase
      include FormHelper
      ITERATOR = PdfFill::HashConverter::ITERATOR

      # rubocop:disable Layout/LineLength
      KEY = {
        'veteran_information': {
          'full_name': {
            'first': {
              key: 'F[0].Page_9[0].Veteran_Service_Member_First_Name[0]',
              limit: 12,
              question_num: 2,
              question_text: 'Veteran / Service Member Name. Enter First Name.'
            },
            'middleInitial': {
              key: 'F[0].Page_9[0].Veteran_Service_Member_Middle_Initial[0]',
              limit: 1,
              question_num: 2,
              question_text: 'Veteran / Service Member Name. Enter Middle Initial.'
            },
            'last': {
              key: 'F[0].Page_9[0].Veteran_Service_Member_Last_Name[0]',
              limit: 18,
              question_num: 2,
              question_text: 'Veteran / Service Member Name. Enter Last Name.'
            }
          },
          'ssn': {
            'first': {
              key: 'F[0].Page_9[0].SocialSecurityNumber_FirstThreeNumbers[0]',
              limit: 3,
              question_num: 3,
              question_text: 'Veteran\'s Social Security Number. Enter first three numbers.'
            },
            'second': {
              key: 'F[0].Page_9[0].SocialSecurityNumber_SecondTwoNumbers[0]',
              limit: 2,
              question_num: 3,
              question_text: 'Veteran\'s Social Security Number. Enter middle two numbers.'
            },
            'third': {
              key: 'F[0].Page_9[0].SocialSecurityNumber_LastFourNumbers[0]',
              limit: 4,
              question_num: 3,
              question_text: 'Veteran\'s Social Security Number. Enter last four numbers.'
            }
          },
          'va_file_number': {
            key: 'F[0].Page_9[0].VA_File_Number[0]',
            limit: 9,
            question_num: 5,
            question_text: 'V. A. File Number. Enter nine digit file number.'
          },
          'birth_date': {
            'month': {
              key: 'F[0].Page_9[0].Date_Of_Birth_Month[0]',
              limit: 2,
              question_num: 6,
              question_text: 'Date of Birth. Enter 2 digit Month.'
            },
            'day': {
              key: 'F[0].Page_9[0].Date_Of_Birth_Day[0]',
              limit: 2,
              question_num: 6,
              question_text: 'Date of Birth. Enter 2 digit day.'
            },
            'year': {
              key: 'F[0].Page_9[0].Date_Of_Birth_Year[0]',
              limit: 4,
              question_num: 6,
              question_text: 'Date of Birth. Enter 4 digit year.'
            }
          },
          'service_number': {
            key: 'F[0].Page_9[0].Veterans_Service_Number_If_Applicable[0]',
            limit: 9,
            question_num: 7,
            question_text: 'Veteran\'s Service Number (If applicable). Enter 9 digits.'
          },
          'gender': {
            'button': {
              'male': {
                key: 'F[0].Page_9[0].Male[0]',
                question_num: 8,
                question_text: 'SEX. Check box. MALE.'
              },
              'female': {
                key: 'F[0].Page_9[0].Female[0]',
                question_num: 8,
                question_text: 'Check box. FEMALE.'
              },
              'other': {
                key: '',
                question_num: 8,
                question_text: ''
              }
            }
          }
        }, # end veteran_information
        'alternateNames': {
          'first': {
            key: 'F[0].#subform[9].List_Other_Name_You_Served_Under[0]',
            question_num: 18,
            question_suffix: 'B',
            question_text: 'LIST THE OTHER NAME(S) YOU SERVED UNDER.'
          },
          'middle': {
            key: 'F[0].#subform[9].List_Other_Name_You_Served_Under[0]',
            question_num: 18,
            question_suffix: 'B',
            question_text: 'LIST THE OTHER NAME(S) YOU SERVED UNDER.'
          },
          'last': {
            key: 'F[0].#subform[9].List_Other_Name_You_Served_Under[0]',
            question_num: 18,
            question_suffix: 'B',
            question_text: 'LIST THE OTHER NAME(S) YOU SERVED UNDER.'
          }
        },
        'serviceInformation': {
          'servicePeriods': {
            'serviceBranch': {
              'army': {
                key: 'F[0].#subform[10].Army[1]',
                question_num: 24,
                question_suffix: 'C',
                question_text: 'Branch of Service. Check box. Army.'
              },
              'navy': {
                key: 'F[0].#subform[10].Navy[1]',
                question_num: 24,
                question_suffix: 'C',
                question_text: 'Branch of Service. Check box. Navy.'
              },
              'marine_corps': {
                key: 'F[0].#subform[10].Marine_Corps[1]',
                question_num: 24,
                question_suffix: 'C',
                question_text: 'Check box. Marine Corps.'
              },
              'air_force': {
                key: 'F[0].#subform[10].Air_Force[1]',
                question_num: 24,
                question_suffix: 'C',
                question_text: 'Check box. Air Force.'
              },
              'coast_guard': {
                key: 'F[0].#subform[10].Coast_Guard[1]',
                question_num: 24,
                question_suffix: 'C',
                question_text: 'Check box. Coast Guard.'
              }
            },
            'dateRange': {
              'from': {
                'month': {
                  key: 'F[0].#subform[9].EntryDate_Month[0]',
                  limit: 2,
                  question_num: 20,
                  question_suffix: 'A',
                  question_text: 'Most recent active service entry date(s). Enter 2 digit month.'
                },
                'day': {
                  key: 'F[0].#subform[9].EntryDate_Day[0]',
                  limit: 2,
                  question_num: 20,
                  question_suffix: 'A',
                  question_text: 'Most recent active service entry date. Enter 2 digit day.'
                },
                'year': {
                  key: 'F[0].#subform[9].EntryDate_Year[0]',
                  limit: 4,
                  question_num: 20,
                  question_suffix: 'A',
                  question_text: 'Most recent active service entry date. Enter 4 digit Year.'
                }
              },
              'to': {
                'month': {
                  key: 'F[0].#subform[9].ExitDate_Month[0]',
                  limit: 2,
                  question_num: 20,
                  question_suffix: 'A',
                  question_text: 'Most recent active service exit date. Enter 2 digit month.'
                },
                'day': {
                  key: 'F[0].#subform[9].ExitDate_Day[0]',
                  limit: 2,
                  question_num: 20,
                  question_suffix: 'A',
                  question_text: 'Most recent active service exit date. Enter 2 digit day.'
                },
                'year': {
                  key: 'F[0].#subform[9].ExitDate_Year[0]',
                  limit: 4,
                  question_num: 20,
                  question_suffix: 'A',
                  question_text: 'Most recent active service exit date. Enter 4 digit Year.'
                }
              }
            }
          },
          'separationLocation': {
            'separationLocationCode': {
              # don't have this in the form 21-526EZ PDF
            },
            'separationLocationName': {
              'line_1_1': {
                key: 'F[0].#subform[9].PlaceOfLastOrAnticipatedSeparation[0]',
                linit: 15,
                question_num: 20,
                question_suffix: 'B',
                question_text: 'Place of last or anticipated separation. Line 1 of 2.'
              },
              'line_1_2': {
                key: 'F[0].#subform[9].PlaceOfLastOrAnticipatedSeparation[1]',
                linit: 15,
                question_num: 20,
                question_suffix: 'B',
                question_text: 'Place of last or anticipated separation. Line 2 of 2.'
              }
            }
          },
          'reservesNationalGuardService': {
            'unitName': {
              'line_1_2': {
                key: 'F[0].#subform[9].CurrentOrLastAssignedNameAndAddressOfUnit[0]',
                linit: 15,
                question_num: 21,
                question_suffix: 'D',
                question_text: 'Current or last assigned name and address of unit. Line 1 of 2.'
              },
              'line_2_2': {
                key: 'F[0].#subform[9].CurrentOrLastAssignedNameAndAddressOfUnit[1]',
                linit: 15,
                question_num: 21,
                question_suffix: 'D',
                question_text: 'Current or last assigned name and address of unit. Line 2 of 2.'
              }
            },
            'obligationTermOfServiceDateRange': {
              'from': {
                'month': {
                  key: 'F[0].#subform[9].ObligationTermOfService_Month[0]',
                  question_num: 21,
                  question_suffix: 'C',
                  question_text: 'Obligation Term of Service. From Date. Enter 2 digit month.'
                },
                'day': {
                  key: 'F[0].#subform[9].ObligationTermOfService_Day[0]',
                  question_num: 21,
                  question_suffix: 'C',
                  question_text: 'From Date. Enter 2 digit day.'
                },
                'year': {
                  key: 'F[0].#subform[9].ObligationTermOfService_Year[0]',
                  question_num: 21,
                  question_suffix: 'C',
                  question_text: 'From Date. Enter 4 digit Year.'
                }
              },
              'to': {
                'month': {
                  key: 'F[0].#subform[9].ObligationTermOfService_Month[1]',
                  question_num: 21,
                  question_suffix: 'C',
                  question_text: 'Obligation Term of Service. To Date. Enter 2 digit month.'
                },
                'day': {
                  key: 'F[0].#subform[9].ObligationTermOfService_Day[1]',
                  question_num: 21,
                  question_suffix: 'C',
                  question_text: 'To Date. Enter 2 digit day.'
                },
                'year': {
                  key: 'F[0].#subform[9].ObligationTermOfService_Year[1]',
                  question_num: 21,
                  question_suffix: 'C',
                  question_text: 'To Date. Enter 4 digit Year.'
                }
              }
            },
            'receivingTrainingPay': {
              'checkbox': {
                key: 'F[0].#subform[10].Do_NOT_Pay_Me_VA_Compensation_I_Do_Not_Want_To_Receive_VA_Compensation_In_Lieu_Of_Training_Pay[0]',
                question_num: 28
              }
            },
            'title10Activation': {
              'title10ActivationDate': {
                'month': {
                  key: 'F[0].#subform[9].DateOfActivation_Month[0]',
                  question_num: 22,
                  question_suffix: 'B',
                  question_text: 'Date of Activation. Enter 2 digit month.'
                },
                'day': {
                  key: 'F[0].#subform[9].DateOfActivation_Day[0]',
                  question_num: 22,
                  question_suffix: 'B',
                  question_text: 'Date of Activation. Enter 2 digit day.'
                },
                'year': {
                  key: 'F[0].#subform[9].DateOfActivation_Year[0]',
                  question_num: 22,
                  question_suffix: 'B',
                  question_text: 'Date of Activation. Enter 4 digit Year.'
                }
              },
              'anticipatedSeparationDate': {
                'month': {
                  key: 'F[0].#subform[9].AnticipatedSeparationDate_Month[0]',
                  question_num: 22,
                  question_suffix: 'C',
                  question_text: 'Anticipated separation date. Enter 2 digit month.'
                },
                'day': {
                  key: 'F[0].#subform[9].AnticipatedSeparationDate_Day[0]',
                  question_num: 22,
                  question_suffix: 'C',
                  question_text: 'Anticipated separation date. Enter 2 digit day.'
                },
                'year': {
                  key: 'F[0].#subform[9].AnticipatedSeparationDate_Year[0]',
                  question_num: 22,
                  question_suffix: 'C',
                  question_text: 'Anticipated separation date. Enter 4 digit Year.'
                }
              }
            }
          }
        },
        'confinements': {
          'first': {
            'from': {
              'month': {
                key: 'F[0].#subform[9].DatesOfConfinement_Month[0]',
                question_num: 23,
                question_suffix: 'B',
                question_text: 'Dates of confinement. From Date. Enter 2 digit month.'
              },
              'day': {
                key: 'F[0].#subform[9].DatesOfConfinement_Day[0]',
                question_num: 23,
                question_suffix: 'B',
                question_text: 'Dates of confinement. From Date. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].#subform[9].DatesOfConfinement_Year[0]',
                question_num: 23,
                question_suffix: 'B',
                question_text: 'Dates of confinement. From Date. Enter 4 digit Year.'
              }
            },
            'to': {
              'month': {
                key: 'F[0].#subform[9].DatesOfConfinement_Month[1]',
                question_num: 23,
                question_suffix: 'B',
                question_text: 'Dates of confinement. To Date. Enter 2 digit month.'
              },
              'day': {
                key: 'F[0].#subform[9].DatesOfConfinement_Day[1]',
                question_num: 23,
                question_suffix: 'B',
                question_text: 'Dates of confinement. To Date. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].#subform[9].DatesOfConfinement_Year[1]',
                question_num: 23,
                question_suffix: 'B',
                question_text: 'Dates of confinement. To Date. Enter 4 digit Year.'
              }
            }
          },
          'second': {
            'from': {
              'month': {
                key: 'F[0].#subform[9].DatesOfConfinement_Month[2]',
                question_num: 23,
                question_suffix: 'B',
                question_text: 'Dates of confinement. From Date. Enter 2 digit month.'
              },
              'day': {
                key: 'F[0].#subform[9].DatesOfConfinement_Day[2]',
                question_num: 23,
                question_suffix: 'B',
                question_text: 'Dates of confinement. From Date. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].#subform[9].DatesOfConfinement_Year[2]',
                question_num: 23,
                question_suffix: 'B',
                question_text: 'Dates of confinement. From Date. Enter 4 digit Year.'
              }
            },
            'to': {
              'month': {
                key: 'F[0].#subform[9].DatesOfConfinement_Month[3]',
                question_num: 23,
                question_suffix: 'B',
                question_text: 'Dates of confinement. To Date. Enter 2 digit month.'
              },
              'day': {
                key: 'F[0].#subform[9].DatesOfConfinement_Day[3]',
                question_num: 23,
                question_suffix: 'B',
                question_text: 'Dates of confinement. To Date. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].#subform[9].DatesOfConfinement_Year[3]',
                question_num: 23,
                question_suffix: 'B',
                question_text: 'Dates of confinement. To Date. Enter 4 digit Year.'
              }
            }
          }
        },
        'militaryRetiredPayBranch': {
          'checkbox': {
            'army': {
              key: 'F[0].#subform[10].Army[1]',
              question_num: 24,
              question_suffix: 'C',
              question_text: 'Branch of Service (Check all that apply). Army.'
            },
            'navy': {
              key: 'F[0].#subform[10].Navy[1]',
              question_num: 24,
              question_suffix: 'C',
              question_text: 'Navy.'
            },
            'marine_corps': {
              key: 'F[0].#subform[10].Marine_Corps[1]',
              question_num: 24,
              question_suffix: 'C',
              question_text: 'Marine Corps.'
            },
            'air_force': {
              key: 'F[0].#subform[10].Air_Force[1]',
              question_num: 24,
              question_suffix: 'C',
              question_text: 'Air Force.'
            },
            'coast_guard': {
              key: 'F[0].#subform[10].Coast_Guard[1]',
              question_num: 24,
              question_suffix: 'C',
              question_text: 'Coast Guard.'
            }
          }
        },
        'waiveRetirementPay': {
          'button': {
            key: 'F[0].#subform[10].Do_Not_Pay_Me_VA_Compensation_I_Do_Not_Want_To_Receive-VA_Compensation_In_Lieu_Of_Retired_Pay[0]',
            question_num: 26,
            question_text: 'Do NOT pay me V. A. compensation. I do NOT want to receive V. A. compensation in lieu of retired pay.'
          }
        },
        'hasSeparationPay': {
          question_num: 27,
          question_suffix: 'A',
          question_text: 'HAVE YOU EVER RECEIVED SEPARATION PAY, DISABILITY PAY, OR ANY OTHER LUMP SUM PAYMENT FROM YOUR BRANCH OF SERVICE?',
          'checkbox': {
            'yes': {
              key: 'F[0].#subform[10].Yes[2]',
              question_num: 27,
              question_suffix: 'A',
              question_text: 'YES. If "Yes," complete Items 27. B through 27. D.'
            },
            'no': {
              key: 'F[0].#subform[10].No[0]',
              question_num: 27,
              question_suffix: 'A',
              question_text: 'NO.'
            }
          }
        },
        'separationPayDate': {
          'month': {
            key: 'F[0].#subform[10].DatePaymentReceived_Month[0]',
            question_num: 27,
            question_suffix: 'B',
            question_text: 'Date payment received. Enter 2 digit month.'
          },
          'day': {
            key: 'F[0].#subform[10].DatePaymentReceived_Day[0]',
            question_num: 27,
            question_suffix: 'B',
            question_text: 'Date payment received. Enter 2 digit day.'
          },
          'year': {
            key: 'F[0].#subform[10].DatePaymentReceived_Year[0]',
            question_num: 27,
            question_suffix: 'B',
            question_text: 'Date payment received. Enter 4 digit Year.'
          }
        },
        'separationPayBranch': {
          'checkbox': {
            'army': {
              key: 'F[0].#subform[10].Army[2]',
              question_num: 27,
              question_suffix: 'C',
              question_text: 'Branch of Service (Check all that apply). Army.'
            },
            'navy': {
              key: 'F[0].#subform[10].Navy[2]',
              question_num: 27,
              question_suffix: 'C',
              question_text: 'Navy.'
            },
            'marine_corps': {
              key: 'F[0].#subform[10].Marine_Corps[2]',
              question_num: 27,
              question_suffix: 'C',
              question_text: 'Marine Corps.'
            },
            'air_force': {
              key: 'F[0].#subform[10].Air_Force[2]',
              question_num: 27,
              question_suffix: 'C',
              question_text: 'Air Force.'
            },
            'coast_guard': {
              key: 'F[0].#subform[10].Coast_Guard[2]',
              question_num: 27,
              question_suffix: 'C',
              question_text: 'Coast Guard.'
            }
          }
        },
        'hasTrainingPay': {
          # seems to be duplicate of `waiveTrainingPay`
        },
        'waiveTrainingPay': {
          'checkbox': {
            key: 'F[0].#subform[10].Do_NOT_Pay_Me_VA_Compensation_I_Do_Not_Want_To_Receive_VA_Compensation_In_Lieu_Of_Training_Pay[0]',
            question_num: 28
          }
        },
        'newPrimaryDisabilities': { # Section IV: Claim Information, Q16 ???
          'condition': {
          },
          'cause': {
          },
          'classificationCode': {
          },
          'primaryDescription': {
          },
          'causedByDisability': {
          },
          'causedByDisabilityDescription': {
          },
          'specialIssues': {
            # enum: %w[ALS HEPC POW PTSD/1 PTSD/2 PTSD/3 PTSD/4 MST PRD]
          },
          'worsenedDescription': {
          },
          'worsenedEffects': {
          },
          'vaMistreatmentDescription': {
          },
          'vaMistreatmentLocation': {
          },
          'vaMistreatmentDate': {
          }
        },
        'newSecondaryDisabilities': { # Section IV: Claim Information, Q16 ???
          'name': {
          },
          'disabilityActionType': {
            # enum: %w[NONE NEW SECONDARY INCREASE REOPEN]
          },
          'specialIssues': {
            # enum: %w[ALS HEPC POW PTSD/1 PTSD/2 PTSD/3 PTSD/4 MST PRD]
          },
          'ratedDisabilityId': {
          },
          'diagnosticCode': {
          },
          'classificationCode': {
          }
        },
        'mailingAddress': { # Section I: Indentificaton And Claim Information, Q11
          'country': {
            key: 'F[0].Page_9[0].CurrentMailingAddress_Country[0]',
            limit: 2,
            qestion_num: 11,
            question_text: 'Current Mailing Address. Enter Country.'
          },
          'addressLine1': {
            key: 'F[0].Page_9[0].CurrentMailingAddress_NumberAndStreet[0]',
            limit: 30,
            qestion_num: 11,
            question_text: 'Current Mailing Address. Enter Number and Street.'
          },
          'addressLine2': {
            key: 'F[0].Page_9[0].CurrentMailingAddress_ApartmentOrUnitNumber[0]',
            limit: 5,
            qestion_num: 11,
            question_text: 'Current Mailing Address. Enter Apartment or Unit Number.'
          },
          'addressLine3': {
          },
          'city': {
            key: 'F[0].Page_9[0].CurrentMailingAddress_City[0]',
            limit: 18,
            qestion_num: 11,
            question_text: 'Current Mailing Address. Enter City.'
          },
          'state': {
            key: 'F[0].Page_9[0].CurrentMailingAddress_StateOrProvince[0]',
            limit: 2,
            qestion_num: 11,
            question_text: 'Current Mailing Address. Enter State or Province.'
          },
          'zipCode': {
            'first_five': {
              key: 'F[0].Page_9[0].CurrentMailingAddress_ZIPOrPostalCode_FirstFiveNumbers[0]',
              limit: 5,
              qestion_num: 11,
              question_text: 'Current Mailing Address. Enter ZIP or Postal Code. First 5 digits.'
            },
            'last_four': {
              key: 'F[0].Page_9[0].CurrentMailingAddress_ZIPOrPostalCode_LastFourNumbers[0]',
              limit: 4,
              qestion_num: 11,
              question_text: 'Current Mailing Address. Enter ZIP or Postal Code. Enter last 4 digits.'
            }
          }
        },
        'forwardingAddress': { # Section II: Change of Address, Q14B
          'country': {
            key: 'F[0].Page_9[0].New_Address_Country[0]',
            limit: 2,
            question_num: 14,
            question_suffic: 'B',
            question_text: 'New Address. Enter Country.'
          },
          'addressLine1': {
            key: 'F[0].Page_9[0].New_Address_NumberAndStreet[0]',
            limit: 30,
            question_num: 14,
            question_suffic: 'B',
            question_text: 'New Address. Enter Number and Street.'
          },
          'addressLine2': {
            key: 'F[0].Page_9[0].New_Address_ApartmentOrUnitNumber[0]',
            limit: 5,
            question_num: 14,
            question_suffic: 'B',
            question_text: 'New Address. Enter Apartment or Unit Number.'
          },
          'addressLine3': {
          },
          'city': {
            key: 'F[0].Page_9[0].New_Address_City[0]',
            limit: 18,
            question_num: 14,
            question_suffic: 'B',
            question_text: 'New Address. Enter City.'
          },
          'state': {
            key: 'F[0].Page_9[0].New_Address_StateOrProvince[0]',
            limit: 2,
            question_num: 14,
            question_suffic: 'B',
            question_text: 'New Address. Enter State or Province.'
          },
          'zipCode': {
            'first_five': {
              key: 'F[0].Page_9[0].New_Address_ZIPOrPostalCode_FirstFiveNumbers[0]',
              limit: 2,
              question_num: 14,
              question_suffic: 'B',
              question_text: 'New Address. Enter ZIP or Postal Code. First 5 digits.'
            },
            'last_four': {
              key: 'F[0].Page_9[0].New_Address_ZIPOrPostalCode_LastFourNumbers[0]',
              limit: 4,
              question_num: 14,
              question_suffic: 'B',
              question_text: 'New Address. Enter ZIP or Postal Code. Enter last 4 digits.'
            }
          },
          'effectiveDate': { # Section II: Change of Address, Q14C
            'form': {
              'month': {
                key: 'F[0].Page_9[0].Beginning_Date_Month[0]',
                limit: 2,
                question_num: 14,
                question_suffic: 'C',
                question_text: 'Beginning Date. Enter 2 digit Month.'
              },
              'day': {
                key: 'F[0].Page_9[0].Beginning_Date_Day[0]',
                limit: 2,
                question_num: 14,
                question_suffic: 'C',
                question_text: 'Beginning Date. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].Page_9[0].Beginning_Date_Year[0]',
                limit: 4,
                question_num: 14,
                question_suffic: 'C',
                question_text: 'Beginning Date. Enter 4 digit year.'
              }
            },
            'to': {
              'month': {
                key: 'F[0].Page_9[0].Ending_Date_Month[0]',
                limit: 2,
                question_num: 14,
                question_suffic: 'C',
                question_text: 'Ending Date. Enter 2 digit Month.'
              },
              'day': {
                key: 'F[0].Page_9[0].Ending_Date_Day[0]',
                limit: 2,
                question_num: 14,
                question_suffic: 'C',
                question_text: 'Ending Date. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].Page_9[0].Ending_Date_Year[0]',
                limit: 4,
                question_num: 14,
                question_suffic: 'C',
                question_text: 'Ending Date. Enter 4 digit year.'
              }
            }
          }
        },
        'phoneAndEmail': {
          'primaryPhone': {
            'country_code': {
              key: 'F[0].Page_9[0].International_Telephone_Number_If_Applicable[0]',
              question_text: 'Enter International Phone Number (If applicable).'
            },
            'area_code': {
              key: 'F[0].Page_9[0].Daytime_Phone_Number_Area_Code[0]',
              question_number: 10,
              limit: 3,
              question_text: 'TELEPHONE NUMBER(S) (Optional) (Include Area Code). Daytime. Enter Area Code.'
            },
            'prefix': {
              key: 'F[0].Page_9[0].Daytime_Phone_Middle_Three_Numbers[0]',
              question_number: 10,
              limit: 3,
              question_text: 'TELEPHONE NUMBER(S). Daytime. Enter middle three numbers.'
            },
            'line_number': {
              key: 'F[0].Page_9[0].Daytime_Phone_Last_Four_Numbers[0]',
              question_number: 10,
              limit: 4,
              question_text: 'TELEPHONE NUMBER(S). Daytime. Enter last four numbers.'
            }
          },
          'emailAddress': {
            key: 'F[0].Page_9[0].Email_Address_Optional[0]',
            limit: 25,
            question_num: 12
          }
        },
        'homelessOrAtRisk': { # NOTE: combines 15A (currently homeless?) and 15C (risk at becoming homeless?)
          'homeless': {
            'button': {
              'yes': {
                key: 'F[0].Page_10[0].YES[0]',
                question_num: 15,
                question_suffix: 'A',
                question_text: 'ARE YOU CURRENTLY HOMELESS? Check box. YES. (If "Yes," complete Item 15. B. regarding your living situation).ARE YOU CURRENTLY HOMELESS? Check box. YES. (If "Yes," complete Item 15. B. regarding your living situation).'
              },
              'no': {
                key: 'F[0].Page_10[0].NO[0]',
                question_num: 15,
                question_suffix: 'A',
                question_text: 'Check box. NO.'
              }
            }
          },
          'at_riks': {
            'button': {
              'yes': {
                key: 'F[0].Page_10[0].YES[1]',
                question_num: 15,
                question_suffix: 'C',
                question_text: 'ARE YOU CURRENTLY AT RISK OF BECOMING HOMELESS? Check box. YES. (If "Yes," complete Item 15. D. regarding your living situation).'
              },
              'no': {
                key: 'F[0].Page_10[0].NO[1]',
                question_num: 15,
                question_suffix: 'A',
                question_text: 'Check box. NO.'
              }
            }
          }
        },
        'homelessHousingSituation': { # 15B
          'checkbox': {
            'shelter': {
              key: 'F[0].Page_10[0].Living_In_A_Homeless_Shelter[0]',
              question_num: 15,
              question_suffix: 'B',
              question_text: 'CHECK THE BOX THAT APPLIES TO YOUR LIVING SITUATION. Check box. Living in a homeless shelter.'
            },
            'not_shelter': {
              key: 'F[0].Page_10[0].Not_Currently_In_A_Sheltered_Environment_e\.g\._Living_In_A_Car_Or_Tent[0]',
              question_num: 15,
              question_suffix: 'B',
              question_text: 'Check box. Not currently in a sheltered environment (e.g., living in a car or tent).'
            },
            'another_person': {
              key: 'F[0].Page_10[0].Staying_With_Another_Person[0]',
              question_num: 15,
              question_suffix: 'B',
              question_text: 'Check box. Staying with another person.'
            },
            'fleeing': {
              key: 'F[0].Page_10[0].Fleeing_Current_Residence[0]',
              question_num: 15,
              question_suffix: 'B',
              question_text: 'Check box. Fleeing current residence.'
            },
            'other': {
              key: 'F[0].Page_10[0].OTHER_Specify[0]',
              question_num: 15,
              question_suffix: 'B',
              question_text: 'Check box. Other (Specify).'
            }
          }
        },
        'otherHomelessHousing': { # 15B OTHER
          key: 'F[0].Page_10[0].SPECIFY_OTHER_LIVING_SITUATION[0]',
          linit: 10,
          question_num: 15,
          question_suffix: 'B',
          question_text: 'SPECIFY OTHER LIVING SITUATION.'
        },
        'needToLeaveHousing': { # 15C
          'button': {
            'yes': {
              key: 'F[0].Page_10[0].YES[1]',
              question_num: 15,
              question_suffix: 'C',
              question_text: 'ARE YOU CURRENTLY AT RISK OF BECOMING HOMELESS? Check box. YES. (If "Yes," complete Item 15. D. regarding your living situation).'
            },
            'no': {
              key: 'F[0].Page_10[0].NO[1]',
              question_num: 15,
              question_suffix: 'C',
              question_text: 'Check box. NO.'
            }
          }
        },
        'atRiskHousingSituation': { # Q15D
          'checkbox': {
            'lost': {
              key: 'F[0].Page_10[0].Housing_Will_Be_Lost_In_30_Days[0]',
              question_num: 15,
              question_suffix: 'D',
              question_text: 'CHECK THE BOX THAT APPLIES TO YOUR LIVING SITUATION. Check box. Housing will be lost in 30 days.'
            },
            'public_housing': {
              key: 'F[0].Page_10[0].Leaving_Publicly_Funded_System_Of_Care_e\.g\._Homeless_Shelter[0]',
              question_num: 15,
              question_suffix: 'D',
              question_text: 'Check box. Leaving publicly funded system of care. (e.g., homeless shelter).'
            },
            'other': {
              key: 'F[0].Page_10[0].OTHER_Specify[1]',
              question_num: 15,
              question_suffix: 'D',
              question_text: 'Check box. Other (Specify).'
            }
          }
        },
        'otherAtRiskHousing': { # Q15D OTHER (specify)
          key: 'F[0].Page_10[0].SPECIFY_OTHER_LIVING_SITUATION[1]',
          limit: 10,
          'question_num': 15,
          'question_suffix': 'D',
          'question_text': 'SPECIFY OTHER LIVING SITUATION.'
        },
        'homelessnessContact': {
          'name': { # 15E
            key: 'F[0].Page_10[0].Point_Of_Contact_Name_Of_Person_VA_Can_Contact_In_Order_To_Get_In_Touch_With_You[0]',
            limit: 20,
            question_num: 15,
            question_suffix: 'E',
            question_text: 'POINT OF CONTACT (Name of person V. A. can contact in order to get in touch with you).'
          },
          'phoneNumber': { # 15F
            key: 'F[0].Page_10[0].PointOfContactTelephoneNumber_Include_Area_Code[0]',
            limit: 10,
            question_num: 15,
            question_suffix: 'F',
            question_text: 'POINT OF CONTACT TELEPHONE NUMBER (Include Area Code).'
          }
        },
        'isTerminallyIll': { # NOTE: no corresponding question on the form
        },
        # "vaTreatmentFacilities": [
        #   {
        #     "treatmentCenterName": "Treatment Center the First",
        #     "treatmentDateRange": {
        #       "from": "2008-01-XX"
        #     },
        #     "treatmentCenterAddress": {
        #       "country": "USA",
        #       "city": "Bigcity",
        #       "state": "AK"
        #     },
        #     "treatedDisabilityNames": [
        #       "knee replacement"
        #     ]
        #   }
        # ],
        'vaTreatmentFacilities': {
          'treatmentCenterName': { # Q17A
            'line_1_4': {
              key: 'F[0].#subform[9].Enter_Disability_Treated_And_Name_And_Location_Of_Treatment_Facility[0]',
              question_num: 17,
              question_suffix: 'A',
              question_text: 'Enter the Disability Treated and Name and Location of the Treatment Facility. Line 1 of 4.'
            },
            'line_2_4': {
              key: 'F[0].#subform[9].Enter_Disability_Treated_And_Name_And_Location_Of_Treatment_Facility[1]',
              question_num: 17,
              question_suffix: 'A',
              question_text: 'Enter Disability Treated and Name and Location of the Treatment Facility. Line 2 of 4.'
            },
            'line_3_4': {
              key: 'F[0].#subform[9].Enter_Disability_Treated_And_Name_And_Location_Of_Treatment_Facility[2]',
              question_num: 17,
              question_suffix: 'A',
              question_text: 'Enter Disability Treated and Name and Location of the Treatment Facility. Line 3 of 4.'
            },
            'line_4_4': {
              key: 'F[0].#subform[9].Enter_Disability_Treated_And_Name_And_Location_Of_Treatment_Facility[3]',
              question_num: 17,
              question_suffix: 'A',
              question_text: 'Enter Disability Treated and Name and Location of the Treatment Facility. Line 4 of 4.'
            }
          },
          'treatmentCenterAddress': { # Q17A
            'line_2_4': {
              key: 'F[0].#subform[9].Enter_Disability_Treated_And_Name_And_Location_Of_Treatment_Facility[1]',
              question_num: 17,
              question_suffix: 'A',
              question_text: 'Enter Disability Treated and Name and Location of the Treatment Facility. Line 2 of 4.'
            },
            'line_3_4': {
              key: 'F[0].#subform[9].Enter_Disability_Treated_And_Name_And_Location_Of_Treatment_Facility[2]',
              question_num: 17,
              question_suffix: 'A',
              question_text: 'Enter Disability Treated and Name and Location of the Treatment Facility. Line 3 of 4.'
            },
            'line_4_4': {
              key: 'F[0].#subform[9].Enter_Disability_Treated_And_Name_And_Location_Of_Treatment_Facility[3]',
              question_num: 17,
              question_suffix: 'A',
              question_text: 'Enter Disability Treated and Name and Location of the Treatment Facility. Line 4 of 4.'
            }
          },
          'treatmentDateRange': { # Q17B
            'line_1_4': {
              'month': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Month[0]',
                limit: 2,
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 2 digit Month.'
              },
              'year': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Year[0]',
                limit: 4,
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 4 digit year.'
              }
            },
            'line_2_4': {
              'month': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Month[1]',
                limit: 2,
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 2 digit Month.'
              },
              'year': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Year[1]',
                limit: 4,
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 4 digit year.'
              }
            },
            'line_3_4': {
              'month': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Month[2]',
                limit: 2,
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 2 digit Month.'
              },
              'year': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Year[2]',
                limit: 4,
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 4 digit year.'
              }
            },
            'line_4_4': {
              'month': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Month[3]',
                limit: 2,
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 2 digit Month.'
              },
              'year': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Year[3]',
                limit: 4,
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 4 digit year.'
              }
            }
          },
          'treatedDisabilityNames': { # Section IV: Claim Information, Q16, first column (Current Disabilities)
            'line_1_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[0]',
              question_num: 16,
              question_text: 'SECTION 4: CLAIM INFORMATION. 16. CURRENT DISABILITY(IES). Line 1 of 15.'
            },
            'line_2_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[1]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 2 of 15.'
            },
            'line_3_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[2]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 3 of 15.'
            },
            'line_4_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[3]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 4 of 15.'
            },
            'line_5_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[4]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 5 of 15.'
            },
            'line_6_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[5]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 6 of 15.'
            },
            'line_7_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[6]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 7 of 15.'
            },
            'line_8_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[7]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 8 of 15.'
            },
            'line_9_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[8]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 9 of 15.'
            },
            'line_10_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[9]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 10 of 15.'
            },
            'line_11_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[10]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 11 of 15.'
            },
            'line_12_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[11]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 12 of 15.'
            },
            'line_13_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[12]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 13 of 15.'
            },
            'line_14_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[13]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 14 of 15.'
            },
            'line_15_15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[14]',
              question_num: 16,
              question_text: 'CURRENT DISABILITY. Line 15 of 15.'
            }
          }
        },
        'attachments': {
          'name': {
          },
          'confirmationCode': {
          },
          'attachmentId': {
          }
        },
        'bankAccountType': {
          'button': {
            'checking': {
              key: 'F[0].#subform[10].Checking_Account[0]',
              question_num: 30,
              question_text: 'CHECKING ACCOUNT.'
            },
            'savings': {
              key: 'F[0].#subform[10].Savings_Account[0]',
              question_num: 30,
              question_text: 'SAVINGS ACCOUNT. '
            }
          }
        },
        'bankAccountNumber': {
          key: 'F[0].#subform[10].Account_Number[0]',
          limit: 15,
          question_num: 30,
          question_text: 'Account Number. Check only one box below and provide the account number. Enter account number.'
        },
        'bankRoutingNumber': {
          key: 'F[0].#subform[10].Routing_Or_Transit_Number[0]',
          limit: 9,
          question_num: 32,
          question_text: 'ROUTING OR TRANSIT NUMBER (The first nine numbers located at the bottom left of your check).'
        },
        'bankName': {
          'line_1_2': {
            key: 'F[0].#subform[10].Name_Of_Financial_Institution[0]',
            limit: 15,
            question_num: 31,
            question_text: 'NAME OF FINANCIAL INSTITUTION ( Provide the name of the bank where you want your direct deposit). Line 1 of 2.'
          },
          'line_2_2': {
            key: 'F[0].#subform[10].Name_Of_Financial_Institution[1]',
            limit: 15,
            question_num: 31,
            question_text: 'NAME OF FINANCIAL INSTITUTION ( Provide the name of the bank where you want your direct deposit). Line 2 of 2.'
          }
        },
        'standardClaim': {
          'button': {
            'standard': {
              key: 'F[0].Page_9[0].Standard_Claim_Process[0]',
              question_num: 1,
              question_text: 'Check box. Standard Claim Process.'
            },
            'fully_developed': {
              key: 'F[0].Page_9[0].FULLY_DEVELOPED_CLAIM_FDC_PROGRAM[0]',
              question_num: 1,
              question_text: 'Check box. Fully Developed Claim (FDC) Program.'
            },
            'ides': {
              key: 'F[0].Page_9[0].IDES[0]',
              question_num: 1,
              question_text: 'Check box. IDES (Select this option only if you have been referred to the IDES Program by your Military Service Department).'
            },
            'bdd': {
              key: 'F[0].Page_9[0].BDD_Program_Claim[0]',
              question_num: 1,
              question_text: 'Check box. BDD Program Claim. (Select this option only if you meet the criteria for the BDD Program specified on Instruction Page 5).'
            }
          }
        },
        'isVaEmployee': {
          'checkbox': {
            key: 'F[0].Page_9[0].Current_VA_Employee_Check_Box[0]',
            question_num: 13
          }
        },
        'mentalChanges': { # ???
          'depression': {
          },
          'obsessive': {
          },
          'prescription': {
          },
          'substance': {
          },
          'hypervigilance': {
          },
          'agoraphobia': {
          },
          'fear': {
          },
          'other': {
          },
          'otherExplanation': {
          },
          'noneApply': {
          }
        },
        'privateMedicalRecordAttachments': { # NOTE: not implemented
          'name': {
          },
          'confirmationCode': {
          },
          'attachmentId': {
          }
        },
        'completedFormAttachments': { # NOTE: not implemented
          'name': {
          },
          'confirmationCode': {
          },
          'attachmentId': {
          }
        },
        'secondaryAttachment': { # NOTE: not implemented
          'name': {
          },
          'confirmationCode': {
          },
          'attachmentId': {
          }
        },
        'unemployabilityAttachments': { # NOTE: not implemented
          'name': {
          },
          'confirmationCode': {
          },
          'attachmentId': {
          }
        },
        'employmentRequestAttachments': { # NOTE: not implemented
          'name': {
          },
          'confirmationCode': {
          },
          'attachmentId': {
          }
        }
      }.freeze
      # rubocop:enable Layout/LineLength

      def merge_fields(**_fill_options)
        # vet_info
        last_and_suffix
        alternate_names

        bank_name
        bank_account_type
        bank_account_number
        bank_routing_number

        phone_and_email

        service_information

        separation_date

        waive_retirement_pay?

        va_employee?

        claim_type

        homeless_or_at_risk?

        @form_data
      end

      private

      def vet_info
        veteran_information = @form_data['veteran_information']

        # extract middle initial
        veteran_information['full_name'] = extract_middle_i(veteran_information, 'full_name')

        # extract birth date
        veteran_information['birth_date'] = split_date(veteran_information['birth_date'])

        # extract ssn
        ssn = veteran_information['ssn']
        veteran_information['ssn'] = split_ssn(ssn.delete('-')) if ssn.present?

        veteran_information
      end

      # "type": "string",
      # "enum": [
      #   "no",
      #   "homeless",
      #   "atRisk"
      # ]
      def homeless_or_at_risk?
        value = @form_data['homelessOrAtRisk'].downcase

        h = HashWithIndifferentAccess.new(
          'homeless': HashWithIndifferentAccess.new(
            'button': HashWithIndifferentAccess.new(
              'yes': '',
              'no': ''
            )
          ),
          'at_risk': HashWithIndifferentAccess.new(
            'button': HashWithIndifferentAccess.new(
              'yes': '',
              'no': ''
            )
          )
        )

        h['homeless'] = q15a(value)
        h['at_risk'] = q15c(value)

        @form_data['homelessOrAtRisk'] = h
      end

      def q15a(value = '')
        h = HashWithIndifferentAccess.new(
          'button': {
            'yes': select_checkbox(false),
            'no': select_checkbox(false)
          }
        )
        value = value.downcase
        return h unless value.in? %w[no homeless]

        case value.downcase
        when 'no'
          h['button']['no'] = select_checkbox(true)
        when 'homeless'
          h['button']['yes'] = select_checkbox(true)
        end

        h
      end

      def q15c(value = '')
        h = HashWithIndifferentAccess.new(
          'button': {
            'yes': select_checkbox(false),
            'no': select_checkbox(false)
          }
        )
        value = value.downcase
        return h unless value.downcase.in? %w[atrisk]

        h['button']['yes'] = select_checkbox(true) if value.downcase == 'atrisk'

        h
      end

      def claim_type
        ctype = HashWithIndifferentAccess.new(
          'standard': 'Off',
          'fully_developed': 'Off',
          'bdd': 'Off',
          'ides': 'Off'
        )
        value = @form_data['standardClaim']

        return ctype unless value.in? [true, false]

        # NOTE: BDD needs further clarification
        # service_date_range = @form_data['serviceInformation']['servicePeriods'][0]['dateRange']
        # if within_ninety_to_hunredtwenty_days?(service_date_range)
        #   ctype['bdd'] = 1
        #   return @form_data['standardClaim'] = ctype
        # end

        ctype['standard'] = 1 if value == true
        ctype['fully_developed'] = 1 if value == false

        @form_data['standardClaim'] = ctype
      end

      def within_ninety_to_hunredtwenty_days?(service_date_range)
        # NOTE: implementation TBD
      end

      def va_employee?
        value = @form_data['isVaEmployee']
        return 'Off' if value.blank?

        @form_data['isVaEmployee'] = select_checkbox(value)
      end

      def waive_retirement_pay?
        value = @form_data['waiveRetirementPay']
        return 'Off' if value.blank?

        @form_data['waiveRetirementPay'] = select_checkbox(value)
      end

      def separation_date
        spd = @form_data['separationPayDate']
        @form_data['separationPayDate'] = split_date_fields(spd)
      end

      def phone_and_email
        phone = @form_data.dig('phoneAndEmail', 'primaryPhone')
        email = @form_data.dig('phoneAndEmail', 'emailAddress')

        h = HashWithIndifferentAccess.new(
          'primaryPhone': HashWithIndifferentAccess.new(
            'country_code': '',
            'area_code': phone&.slice!(0..2),
            'prefix': phone&.slice!(0..2),
            'line_number': phone
          ),
          'emailAddress': email
        )

        @form_data['phoneAndEmail'] = h
      end

      def bank_name
        bank_name = @form_data['bankName']
        return '' if bank_name.blank?

        @form_data['bankName'] = expand_name(bank_name)
      end

      def bank_account_type
        type = @form_data['bankAccountType']
        return '' if type.blank?

        @form_data['bankAccountType'] = HashWithIndifferentAccess.new(
          'checking': checking?(type),
          'savings': savings?(type)
        )
      end

      def bank_account_number
        account_number = @form_data['bankAccountNumber']

        @form_data['bankAccountNumber'] = account_number&.slice!(0..14)
      end

      def bank_routing_number
        routing_number = @form_data['bankRoutingNumber']

        @form_data['bankAccountNumber'] = routing_number&.slice!(0..8)
      end

      def alternate_names
        names = @form_data['alternateNames']
        @form_data['alternateNames'] = combine_previous_names(names)
      end

      # rubocop:disable Metrics/MethodLength
      def service_information
        service_periods = @form_data.dig('serviceInformation', 'servicePeriods')
        separation_location = @form_data.dig('serviceInformation', 'separationLocation')

        h = HashWithIndifferentAccess.new(
          reservesNationalGuardService: reserves_national_guard_service,
          obligationTermOfServiceDateRange: HashWithIndifferentAccess.new(
            to: '',
            from: ''
          ),
          unitName: '',
          title10Activation: HashWithIndifferentAccess.new(
            title10ActivationDate: '',
            anticipatedSeparationDate: ''
          ),
          servicePeriods: HashWithIndifferentAccess.new(
            serviceBranch: '',
            dateRange: HashWithIndifferentAccess.new(
              to: '',
              from: ''
            )
          ),
          separationLocation: HashWithIndifferentAccess.new(
            separationLocationCode: '',
            separationLocationName: HashWithIndifferentAccess.new(line_1_2: '', line_2_2: '')
          )
        )

        if service_periods
          latest = latest_service_period(service_periods)
          h['servicePeriods']['serviceBranch'] = military_branch_name(latest['serviceBranch'])
          h['servicePeriods']['dateRange']['from'] = split_date_fields(latest['dateRange']['from'])
          h['servicePeriods']['dateRange']['to'] = split_date_fields(latest['dateRange']['to'])
        end

        if separation_location
          h['separationLocation']['separationLocationName'] =
            expand_name(separation_location['separationLocationName'])
        end

        @form_data['serviceInformation'] = h
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def reserves_national_guard_service
        unit_name = @form_data.dig('serviceInformation', 'reservesNationalGuardService', 'unitName')

        HashWithIndifferentAccess.new(
          'unitName': expand_name(unit_name),
          'obligationTermOfServiceDateRange': HashWithIndifferentAccess.new(
            'from': HashWithIndifferentAccess.new(
              'month': '',
              'day': '',
              'year': ''
            ),
            'to': HashWithIndifferentAccess.new(
              'month': '',
              'day': '',
              'year': ''
            )
          ),
          'receivingTrainingPay': '',
          'title10Activation': HashWithIndifferentAccess.new(
            'title10ActivationDate': HashWithIndifferentAccess.new(
              'month': '',
              'day': '',
              'year': ''
            ),
            'anticipatedSeparationDate': HashWithIndifferentAccess.new(
              'month': '',
              'day': '',
              'year': ''
            )
          )
        )
      end
      # rubocop:enable Metrics/MethodLength

      def latest_service_period(service_periods)
        return unless service_periods
        return service_periods.first if service_periods&.size == 1

        service_periods.sort_by! { |k, _v| k['dateRange']['from'] }.reverse!.first
      end

      def expand_yes_no(data)
        return if data.blank?

        @form_data['hasSeparationPay']['checkbox'] = {
          'yes': select_checkbox(data),
          'no': select_checkbox(data)
        }
      end

      def military_branch_name(branch_name)
        return if branch_name.blank?

        {
          'army': army?(branch_name),
          'navy': navy?(branch_name),
          'marine_corps': marines?(branch_name),
          'air_force': airforce?(branch_name),
          'coast_guard': coastguard?(branch_name)
        }
      end

      def army?(value)
        return if value.blank?

        value.downcase.start_with?('army') ? 1 : 'Off'
      end

      def airforce?(value)
        return if value.blank?

        value.downcase.start_with?('air') ? 1 : 'Off'
      end

      def marines?(value)
        return if value.blank?

        value.downcase.start_with?('marine') ? 1 : 'Off'
      end

      def navy?(value)
        return if value.blank?

        value.downcase.start_with?('navy') ? 1 : 'Off'
      end

      def coastguard?(value)
        return if value.blank?

        value.downcase.start_with?('coast') ? 1 : 'Off'
      end

      def split_date_fields(date_fields)
        h = HashWithIndifferentAccess.new('month': '', 'day': '', 'year': '')
        return h if date_fields.blank?

        yyyy, mm, dd = date_fields.split('-')
        h['month'] = mm
        h['day'] = dd
        h['year'] = yyyy

        h
      end

      # NOTE: used for splitting string into two separate 15-char long lines
      #       - bank name
      #       - unit name
      #       - location name
      def expand_name(name)
        HashWithIndifferentAccess.new(
          'line_1_2': name&.slice!(0..14),
          'line_2_2': name&.slice!(0..14)
        )
      end

      def checking?(value = '')
        value.downcase == 'checking' ? 1 : 'Off'
      end

      def savings?(value = '')
        value.downcase == 'savings' ? 1 : 'Off'
      end

      def expand_phone(number)
        return {} unless number

        {
          'country_code': '',
          'area_code': number.slice!(0..2),
          'prefix': number.slice!(0..2),
          'line_number': number
        }
      end

      def last_and_suffix
        last = @form_data.dig('fullName', 'last')
        suffix = @form_data.dig('fullName', 'suffix')

        return if last.blank?

        @form_data['fullName']['last'] = if last.present? && suffix.present?
                                           "#{last} #{suffix}"
                                         elsif last.present?
                                           last
                                         end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
