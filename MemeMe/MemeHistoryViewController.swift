//
//  MemeHistoryViewController.swift
//  MemeMe
//
//  Created by Matt Curtis on 4/04/2015.
//  Copyright (c) 2015 Matt Curtis. All rights reserved.
//

import UIKit

class MemeHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var memes = [Meme]()
    var appDelegate: AppDelegate!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        memes = appDelegate.memes
        tableView?.reloadData()
        collectionView?.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

        if memes.isEmpty {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("CreateMemeViewController") as CreateMemeViewController
            presentViewController(vc, animated: true, completion: nil)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SentMemeTableCell") as UITableViewCell
        let meme = memes[indexPath.row]

        cell.textLabel?.text = meme.topText + "..." + meme.bottomText
        cell.imageView?.image = meme.image

        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let meme = memes[indexPath.row]
        showMemeDetail(meme)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SentMemeCollectionCell", forIndexPath: indexPath) as SentMemeCollectionViewCell
        let meme = memes[indexPath.row]

        cell.imageView?.image = meme.image

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let meme = memes[indexPath.row]
        showMemeDetail(meme)
    }

    func showMemeDetail(meme: Meme) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as MemeDetailViewController
        vc.meme = meme
        //presentViewController(vc, animated: true, completion: nil)
        navigationController?.pushViewController(vc, animated: true)
    }

}
