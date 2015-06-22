//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //This ViewController class conforms to the UITableViewDelegate protocol and UITableViewDataSource protocol
    //This means that we are specifying that this ViewController class will have the methods that are
    //associated with UITableViewDelegate and  UITableViewDataSource classes
    @IBOutlet weak var messageTableView: UITableView!//This shows all the available messages in the app at parse.com
    
    @IBOutlet weak var messageTextField: UITextField!//The user types a message here
    
    @IBOutlet weak var sendButton: UIButton!//User clicks at this button for sending messages to the parse.com server
    
    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!//Height property of the DoccView where the send
    //button and the textfield are shown on the screen.
    
    var messagesArray : [String] = [String]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.messageTableView.dataSource = self;
        self.messageTableView.delegate = self;
        
        //set self as the delegate for the textfield where the user types a message to send it
        self.messageTextField.delegate = self;//self refers to ViewController class
        
        //Add a tap gesture recognizer to the tableview
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped");
        self.messageTableView.addGestureRecognizer(tapGesture);
        
        //Retreive the available messages from the server
        self.retreiveMessages();
        
        self.sendButton.enabled = false;
    }//function viewDidLoad ends here.
    
    @IBAction func sendButtonTapped(sender: UIButton) {
        
        if self.messageTextField.text != ""{
            
            //Call the end editing method for the textfield where the user types the message
            self.messageTextField.endEditing(true);
            
            //Disable the send button and the text field
            self.sendButton.enabled = false;
            self.messageTextField.enabled = false;
            
            //create a PFObject
            //Message is the name of the class at the parse.com server
            var newMessagebject : PFObject = PFObject(className: "Message");
            //set the Text key to the text of the messageTextField
            newMessagebject["Text"] = self.messageTextField.text;
            
            //Save the PFObject
            newMessagebject.saveInBackgroundWithBlock { (successfullySaved, error) -> Void in
                if (successfullySaved == true){
                    //Message has been saved to the parse.com server
                    //Retreive the latest messages and reload the table.
                    NSLog("Message saved successfully.");
                    self.retreiveMessages();
                    
                }else{
                    //Something went wrong. Message was not saved.
                    NSLog(error!.description);
                }
                //We want the userinterface items to get refreshed on the main thread only to avoid freezing the UI
                dispatch_async(dispatch_get_main_queue()){
                    //Enable the textfield and the send button again for next message
                    self.messageTextField.enabled = true;
                    self.messageTextField.text = "";
                    //self.sendButton.enabled = true;
                }
            }
            
        }//if ends here.
    }//function sendButtonTapped ends here.
    
    
    func retreiveMessages(){
        
        //clear the messagesArray so that we do not get duplicate messages
        self.messagesArray = [String]();
        
        //Create a new PFQuery
        var query : PFQuery = PFQuery(className: "Message");
        
        //Execute the query
        query.findObjectsInBackgroundWithBlock { (availableMessages: [AnyObject]?, error: NSError?) -> Void in
            
            //Loops through the availableMessages which are objects of type PFObject
            //Since availableMessages can be nill so we use the if let objes = availableMessages{...for loop...}
            if let objs = availableMessages{
                
                for  someMessage in objs{
                    
                    //Retreive the text column value of each PFObject
                    //Since I am not sure what is there in the Text column of the table Message,
                    //therefore I  use String? instead of String. ? means optional i.e., it could
                    //be null or a string
                    let messageText : String? = (someMessage as! PFObject)["Text"] as? String;
                    
                    //Assign it to the messagesArray
                    if messageText != nil{
                        self.messagesArray.append(messageText!);//The symbol ! unwraps the messageText
                    }
                }
                
            }
            //We want to reload data on the main thread only to avoid freezing the UI
            dispatch_async(dispatch_get_main_queue()){
                //Reload the tableview so that it displays teh latest messages.
                self.messageTableView.reloadData();
            }
            
        }
    }//function retreiveMessages ends here.
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableViewTapped(){
        
        //Force the text field to end editing as the user has tapped outside the text field.
        self.messageTextField.endEditing(true);
        
    }//function tableViewTapped ends here.
    
    
    //Mark: TextField Delegate Methods
    //**********************************
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //enable the send button
        self.sendButton.enabled = true;
        //Perform an animation to grow the dockView to accomodate the keyboard
        self.view.layoutIfNeeded();
        UIView.animateWithDuration(0.5, animations: {
            self.dockViewHeightConstraint.constant = 350;
            self.view.layoutIfNeeded();
            }, completion: nil)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        //Perform animation to shrink DockView back to its original size i.e. 60 pixels
        self.view.layoutIfNeeded();
        UIView.animateWithDuration(0.5, animations: {
            self.dockViewHeightConstraint.constant = 60;
            self.view.layoutIfNeeded();
            }, completion: nil)
    }
    
    //Mark: TableView Delegate Methods
    //********************************
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //create a UITable cell
        //function dequeueReusableCellWithIdentifier will reuse the cell MessageCell but if it
        //does not exist then it will createa a new cell. Since the method does not know what type of
        //cell will be returned, we downcast it to UITableViewCell using as! UITABleViewCell
        let cell = self.messageTableView.dequeueReusableCellWithIdentifier("MessageCell") as! UITableViewCell;
        
        //customize the UITabel cell
        cell.textLabel?.text = self.messagesArray[indexPath.row];//? means optional chaining as the textLabel in the
        //cell is optional and it migt exist or not. It is safer to access or set it that way since if the textLabel
        //does not exist then the app won't crash.
        //return the UITableView cell
        return cell;
    }
    
    
}

