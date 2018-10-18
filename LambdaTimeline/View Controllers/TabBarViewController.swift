//
//  TabBarViewController.swift
//  LambdaTimeline
//
//  Created by De MicheliStefano on 18.10.18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol LambdaTimelineDelegate {
    var postController: PostController! { get set }
}

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let postController = PostController()
        let tabBarChildren = self.children
        
        for navControllers in tabBarChildren {
            if let navControllers = navControllers as? UINavigationController {
                for vc in navControllers.children {
                    if var vc = vc as? LambdaTimelineDelegate {
                        vc.postController = postController
                    }
                }
            }
        }
    }
    

}
