//
//  CommentCell.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-01.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CommentCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    @IBAction func likeComment(_ sender: Any) {
        vote(up: true)
    }
    
    @IBAction func dislikeComment(_ sender: Any) {
        vote(up: false)
    }
    
    var userId: Int?
    var commentId: Int!
    var votedDown: Bool = false {
        didSet{
            dislikeButton.setTitleColor(votedDown ? Color.primary : Color.lightGray, for: .normal)
        }
    }
    
    var votedUp: Bool = false {
        didSet{
            likeButton.setTitleColor(votedUp ? Color.primary : Color.lightGray, for: .normal)
        }
    }
    
    let accountMgr = AccountManager.sharedInstance
    
    
    /**
     If up is true, then vote a up for the comment. Otherwise, vote a down for the comment.
    */
    func vote(up: Bool){
        let headers: HTTPHeaders = [
            "Authorization": accountMgr.fetchToken()?.jwt! ?? "",
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        let parameters: Parameters = [
            "comment_id": commentId,
            "up": up
        ]
        
        let url = Connection.VoteUrl
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON{
            response in
            
            let result = response.result
            
            debugPrint(response)
            switch result{
            case .success:
                self.updateCommentVote(statusCode: (response.response?.statusCode)!, up: up)
                break
            case .failure:
                let message = JSON.init(data: response.data!)["description"].stringValue
                debugPrint(message)
                break
            }
        }
    }
    
    func updateCommentVote(statusCode: Int, up: Bool){
        // Initial Status
        if !votedDown && !votedUp{
            if up && statusCode == 200{
                voteDidFinish(up: true, down: false, offset: 1)
            }else if !up && statusCode == 200{
                voteDidFinish(up: false, down: true, offset: -1)
            }
        }else if votedUp && !votedDown{
            if statusCode == 204{
                voteDidFinish(up: false, down: false, offset: -1)
            }
        }else if !votedUp && votedDown{
            if statusCode == 204{
                voteDidFinish(up: false, down: false, offset: 1)
            }
        }
    }
    
    
    func voteDidFinish(up: Bool, down: Bool, offset: Int){
        votedUp = up
        votedDown = down
        voteCountLabel.text = String(Int(voteCountLabel.text!)! + offset)
    }
    
}
