//
//  FirstMessageTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 18/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import SDWebImage

class MessageTableViewCell: UITableViewCell {
    
    // MARK: - IB Outlets
    
    // Message Infos
    
    @IBOutlet weak var messageInfosStackView: UIStackView!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contentTypeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    // User Pic
    
    @IBOutlet weak var userPicImageView: CircularImageView!
    
    // Message Body
    
    @IBOutlet weak var messageView: RoundedMessageView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var loveIconImageView: UIImageView!
    @IBOutlet weak var loveCountLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    // Embed body
    
    @IBOutlet weak var embedView: UIView!
    @IBOutlet weak var providerPicImageView: UIImageView!
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var contentTitleLabel: UILabel!
    @IBOutlet weak var contentThumbnailImageView: UIImageView!
    
    // MARK: - Properties
    
    // Message Set
    
    var message: UserMessageDto! {
        didSet{
            self.feedCell(message: message)
            self.stylizeCell(message: message)
            self.showLoves(message: message)
        }
    }
    
    // MARK: - Private funcs
    
    private func feedCell(message: UserMessageDto) {
        
        // message infos
        self.contentTypeLabel.isHidden = true
        self.userPicImageView.isHidden = false
        self.messageInfosStackView.isHidden = false
        self.usernameLabel.text = message.author
        self.timeLabel.text = DateHelper
            .HoursWithTimestamp(timestamp: Double(message.createdAt))
        
        // role checking
        switch message.authorRole {
            
        case .admin?:
            self.roleLabel.isHidden = false
            self.roleLabel.text = "Admin".uppercased()
        case .moderator?:
            self.roleLabel.isHidden = false
            self.roleLabel.text = "Modo".uppercased()
        default:
            self.roleLabel.isHidden = true
        }
      
      self.embedView.isHidden = true
      self.messageImageView.isHidden = true
        
        // message type checking
        switch message.type {
            
        // text message
        case .text(let text):
            self.messageLabel.isHidden = false
            self.messageLabel.text = text
            
        // media message
        case .media(let mediaWith, _, let text):
            self.messageImageView.isHidden = false
            
            if text != nil {
                self.messageLabel.isHidden = false
                self.messageLabel.text = text
            }
            
            switch mediaWith {
            case .image(let image):
                self.messageImageView.image = image
            case .url(let url):
                self.messageImageView.sd_setImage(
                    with: URL(string: url),
                    completed: nil)
            }
            
        // embed message
        case .embed(let text, let embed):
            
          if text != nil {
            self.messageLabel.isHidden = false
            self.messageLabel.text = text
          }
            
          self.embedView.isHidden = false
          self.contentTitleLabel.text = embed.title
          self.providerNameLabel.text = embed.providerName
          self.providerPicImageView.sd_setImage(
            with: URL(string: embed.favicon ?? ""),
            completed: nil)
          self.contentThumbnailImageView.sd_setImage(
            with: URL(string: embed.thumbnailUrl ?? ""),
            completed: nil)
          self.contentThumbnailImageView.clipsToBounds = true
            
        // joke message
        case .joke(let joke):
            self.contentTypeLabel.isHidden = false
            self.contentTypeLabel.text = "Blague".uppercased()
            self.messageLabel.text = joke
            
        // quote message
        case .quote(let quote):
            self.contentTypeLabel.isHidden = false
            self.contentTypeLabel.text = "Citation".uppercased()
            self.messageLabel.text = quote
            
        // deleted message
        case .deleted:
            self.messageLabel.text = "Message supprimé"
          
        case .blocked:
          self.messageLabel.text = "Utilisateur bloqué"
      }
        
        if message.authorPic != nil {
            self.userPicImageView.sd_setImage(
                with: URL(string: message.authorPic!),
                completed: nil)
            self.userPicImageView.clipsToBounds = true
        }
        
        self.layoutIfNeeded()
        
    }
    
    // Checking previous message id for style
    
    var previousMessage: UserMessageDto? {
        didSet{
            self.messageInfosStackView.isHidden = previousMessage?.authorId == message.authorId
            self.userPicImageView.isHidden = previousMessage?.authorId == message.authorId
        }
    }
    
    private func stylizeCell(message: UserMessageDto) {
        let color = UIColor(
            hex: ColorGeneratorHelper.getColorwithId(id: message.color))
        self.usernameLabel.textColor = color
        self.userPicImageView.backgroundColor = color
        self.messageView.backgroundColor = color
        self.loveIconImageView.tintColor = color
        self.loveCountLabel.textColor = color
    }
    
    private func showLoves(message: UserMessageDto) {
        if message.love != 0 {
            self.loveCountLabel.isHidden = false
            self.loveIconImageView.isHidden = false
            self.loveCountLabel.text = String(message.love)
        } else {
            self.loveCountLabel.isHidden = true
            self.loveIconImageView.isHidden = true
        }
    }
    
    // MARK: - Prepare for Reuse, reset cell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentTypeLabel.isHidden = true
        self.userPicImageView.image = nil
        self.userPicImageView.sd_cancelCurrentImageLoad()
        self.messageImageView.isHidden = true
        self.messageImageView.image = nil
        self.messageImageView.sd_cancelCurrentImageLoad()
        self.contentThumbnailImageView.image = nil
        self.contentThumbnailImageView.sd_cancelCurrentImageLoad()
        self.embedView.isHidden = true
    }
    
}

