//
//  CustomNavigationBar.swift
//  ToDoApp
//
//  Created by 工藤海斗 on 2020/05/03.
//  Copyright © 2020 工藤海斗. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {
    // NavigationBar height
    var customHeight : CGFloat = 44
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()
        
        
    }
}
