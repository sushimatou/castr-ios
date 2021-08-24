//
//  SelfMessageTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 18/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class SelfMessageTableViewCell: UITableViewCell {
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - IB Outlets
  
  // Message Body
    
  @IBOutlet weak var messageView: RoundedMessageView!
  @IBOutlet weak var messageImageView: UIImageView!
  @IBOutlet weak var messageLabel: UILabel!
    
  // Embed Body
  @IBOutlet weak var embedView: UIView!
  @IBOutlet weak var contentThumbnailImageView: UIImageView!
  @IBOutlet weak var providerIconImageView: UIImageView!
  @IBOutlet weak var providerNameLabel: UILabel!
  @IBOutlet weak var contentTitle: UILabel!
    
  // Others
  @IBOutlet weak var sendProgressView: UIProgressView!
  @IBOutlet weak var sendStatusLabel: UILabel!
  @IBOutlet weak var loveCountLabel: UILabel!
  @IBOutlet weak var loveIconImageView: UIImageView!

  var message: UserMessageDto! {
    didSet{
      self.feedCell(message: message)
      self.stylizeCell(message: message)
      self.showLoves(message: message)
    }
  }
  
  // MARK: - Private funcs
  
  private func feedCell(message: UserMessageDto) {
    
    // sending status checking
    switch message.status {
    case .sending?:
      self.sendProgressView.isHidden = true
      self.sendStatusLabel.isHidden = false
        
    case .uploading(let progression)?:
      let totalCount = progression.totalUnitCount
      let completedCount = progression.completedUnitCount
      let percent = (completedCount*100)/totalCount
      self.sendProgressView.isHidden = false
      self.sendStatusLabel.isHidden = false
      self.sendProgressView.setProgress(Float(percent), animated: true)
        
    default:
      self.sendProgressView.isHidden = true
      self.sendStatusLabel.isHidden = true
    }
    
    // message type checking
    switch message.type {
      
    // text message
    case .text(let text):
      self.messageLabel.isHidden = false
      self.messageLabel.text = text
      //self.messageLabel.sizeToFit()
      
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
      
      self.messageImageView.clipsToBounds = true
      
    // embed message
    case .embed(let text, let embed):
      
      if text != nil {
        self.messageLabel.isHidden = false
        self.messageLabel.text = text
      }
      
      self.embedView.isHidden = false
      self.providerNameLabel.text = embed.providerName
      self.contentThumbnailImageView.sd_setImage(
        with: URL(string: embed.thumbnailUrl ?? ""),
        completed: nil)
      
    // joke message
    case .joke(let joke):
      self.messageLabel.text = joke
      
    // quote message
    case .quote(let quote):
      self.messageLabel.text = quote
      
    // deleted message
    case .deleted:
      self.messageLabel.text = "Message supprimé"
      
    case .blocked:
      break // NOOP
    }
  }
  
  private func stylizeCell(message: UserMessageDto) {
    let color = UIColor(
      hex: ColorGeneratorHelper.getColorwithId(id: message.color))
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
    self.sendProgressView.isHidden = true
    self.sendStatusLabel.isHidden = true
    self.messageImageView.isHidden = true
    self.messageImageView.image = nil
    self.messageImageView.sd_cancelCurrentImageLoad()
    self.contentThumbnailImageView.image = nil
    self.contentThumbnailImageView.sd_cancelCurrentImageLoad()
    self.embedView.isHidden = true
    self.layoutIfNeeded()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.messageImageView.isHidden = true
    self.embedView.isHidden = true
  }
  
}
