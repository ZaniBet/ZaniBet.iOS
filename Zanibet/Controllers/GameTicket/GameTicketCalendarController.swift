//
//  GameTicketCalendarController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 01/02/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit
import Imaginary
//import MoPub

class GameTicketCalendarController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var calendarTableView: UITableView!
    
    var gameticket:GameTicket!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "\(self.gameticket.name.replacingOccurrences(of: " Jackpot", with: "")) J\(self.gameticket.matchday!)"
        self.calendarTableView.delegate = self
        self.calendarTableView.dataSource = self        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gameticket.fixtures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fixtureOddsCell", for: indexPath) as! FixtureOddsCell
        let fixture = self.gameticket.fixtures[indexPath.row]
        var date:String = ""
    
        if let fixtureDate = Date(fromString: fixture.date!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc){
            /*let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "EEE dd MMM HH:mm"*/
            
            //date = dateFormatter.string(from: fixtureDate)
            date = fixtureDate.toString(format: .custom("EEE dd MMM HH:mm"), timeZone: .local).uppercased()
        }
        
        cell.dateLabel.text = date
        cell.homeTeamLabel.text = fixture.homeTeam.shortName ?? fixture.homeTeam.name
        cell.awayTeamLabel.text = fixture.awayTeam.shortName ?? fixture.awayTeam.name
        
        if (HTTPHelper.verifyUrl(urlString: fixture.homeTeam.logo)){
            let imageUrl = URL(string: fixture.homeTeam.logo ?? "")
            var option = Option()
            option.storageMaker = {
                return Configuration.imageStorage
            }
            cell.homeTeamImageView.setImage(url: imageUrl!, option: option)
        } else {
            cell.homeTeamImageView.image = #imageLiteral(resourceName: "zanibet_logo")
        }
        
        if (HTTPHelper.verifyUrl(urlString: fixture.awayTeam.logo)){
            let imageUrl = URL(string: fixture.awayTeam.logo ?? "")
            var option = Option()
            option.storageMaker = {
                return Configuration.imageStorage
            }
            cell.awayTeamImageView.setImage(url: imageUrl!, option: option)
        } else {
            cell.awayTeamImageView.image = #imageLiteral(resourceName: "zanibet_logo")
        }
        
        for odd in fixture.odds! {
            if (odd.bookmaker == "ZaniBet"){
                if let homeOdd:Float = odd.value?.homeTeam {
                    cell.homeOddLabel.text = "\(homeOdd)"
                }
                
                if let drawOdd:Float = odd.value?.draw {
                    cell.drawOddLabel.text = "\(drawOdd)"
                }
                
                if let awayOdd:Float = odd.value?.awayTeam {
                    cell.awayOddLabel.text = "\(awayOdd)"
                }
            } else if (odd.bookmaker == "Players"){
                if let homeOdd:Float = odd.value?.homeTeam {
                    cell.playersHomeOddLabel.text = "\(homeOdd)%"
                }
                
                if let drawOdd:Float = odd.value?.draw {
                    cell.playersDrawOddLabel.text = "\(drawOdd)%"
                }
                
                if let awayOdd:Float = odd.value?.awayTeam {
                    cell.playersAwayOddLabel.text = "\(awayOdd)%"
                }
            }
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 212.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
