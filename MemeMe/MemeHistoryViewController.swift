//
//  MemeHistoryViewController.swift
//  MemeMe
//
//  Created by Matt Curtis on 4/04/2015.
//  Copyright (c) 2015 Matt Curtis. All rights reserved.
//

import UIKit

class MemeHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var memes = [Meme]?()
    var appDelegate: AppDelegate?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        memes = appDelegate?.memes
        tableView?.reloadData()
        collectionView?.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

        if memes?.isEmpty ?? false {
            if let vc = storyboard?.instantiateViewControllerWithIdentifier("CreateMemeViewController") as? CreateMemeViewController {
                presentViewController(vc, animated: true, completion: nil)
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SentMemeTableCell") as! UITableViewCell
        if let meme = memes?[indexPath.row] {
            cell.textLabel?.text = meme.topText + "..." + meme.bottomText
            cell.imageView?.image = meme.image
        }
        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let meme = memes?[indexPath.row] {
            showMemeDetail(meme)
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SentMemeCollectionCell", forIndexPath: indexPath) as! SentMemeCollectionViewCell
        if let meme = memes?[indexPath.row] {
            cell.imageView?.image = meme.image
        }
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let meme = memes?[indexPath.row] {
            showMemeDetail(meme)
        }
    }

    func showMemeDetail(meme: Meme) {
        if let vc = storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as? MemeDetailViewController {
            vc.meme = meme
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
