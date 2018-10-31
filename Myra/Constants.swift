//
//  Constants.swift
//  Myra
//
//  Created by Amir Shayegh on 2018-04-09.
//  Copyright © 2018 Government of British Columbia. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Defaults {
        static let planId = -1
    }

    // dev
    struct API {
        static let maxConcurentEndpointRequests = 3
        static let baseURL = URL(string: "https://api-range-myra-dev.pathfinder.gov.bc.ca/api/v1/")
        //http://10.10.10.190:8000
//        static let baseURL = URL(string: "http://10.10.10.190:8000/api/v1/")
        static let referencePath = "reference/"
        static let planPath = "plan/"
        static let pasturePath = "plan/:id/pasture"
        static let plantCommunityPath = "plan/:planId/pasture/:pastureId/plant-community"
        static let plantCommunityActionPath = "plan/:planId/pasture/:pastureId/plant-community/:plantCommunityId/action"
        static let indicatorPlantPath = "plan/:planId/pasture/:pastureId/plant-community/:plantCommunityId/indicator-plant"
        static let monitoringAreaPath = "plan/:planId/pasture/:pastureId/plant-community/:plantCommunityId/monitoring-area"
        static let invasivePlantsPath = "plan/:planId/invasive-plant-checklist"
        static let agreementPath = "agreement/"
        static let schedulePath = "plan/:id/schedule"
        static let issuePath = "plan/:id/issue"
        static let actionPath = "plan/:planId?/issue/:issueId?/action"
        static let additionalRequirement = "plan/:planId/additional-requirement"
        static let managementConsideration = "plan/:planId/management-consideration"
    }
    
    struct SSO {
        static let baseUrl = URL(string: "https://sso-dev.pathfinder.gov.bc.ca")!
        static let redirectUri = "myra-ios://client"
        static let clientId = "myrangebc"
        static let realmName = "range"
        static let idpHint = ""
    }



    // test
    /*
    struct API {
        static let maxConcurentEndpointRequests = 3
        static let baseURL = URL(string: "https://api-range-myra-test.pathfinder.gov.bc.ca/api/v1/")
        static let planPath = "plan/"
        static let pasturePath = "plan/:id/pasture"
        static let referencePath = "reference/"
        static let agreementPath = "agreement/"
        static let schedulePath = "plan/:id/schedule"
        static let issuePath = "plan/:id/issue"
        static let actionPath = "plan/:planId?/issue/:issueId?/action"
    }

    struct SSO {
        static let baseUrl = URL(string: "https://dev-sso.pathfinder.gov.bc.ca")!
        static let redirectUri = "myra-ios://client"
        static let clientId = "range-test"
        static let realmName = "mobile"
        static let idpHint = ""
    }
    */
}
