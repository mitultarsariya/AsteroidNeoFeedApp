//
//  Utils.swift
//  AsteroidNeoApp
//
//  Created by iMac on 05/08/22.
//

import Foundation
import Reachability


class Utils: NSObject {

    func connected() -> Bool
    {
        let reachability = Reachability.forInternetConnection()
        let status : NetworkStatus = reachability!.currentReachabilityStatus()
        if status == .NotReachable {
            return false
        }
        else
        {
            return true
        }
    }

}
