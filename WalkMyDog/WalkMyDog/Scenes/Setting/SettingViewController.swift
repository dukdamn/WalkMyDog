//
//  SettingPuppyViewController.swift
//  WalkMyDog
//
//  Created by κΉνν on 2021/02/08.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SettingViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Interface Builder
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var settingViewModel: SettingViewModel?
    private var bag = DisposeBag()
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<SettingSectionModel>(configureCell: {
        (dataSource, tableView, indexPath, item) in
        switch item {
        case .PuppyItem(let puppy):
            let cell: PuppyTableViewCell = tableView.dequeueReusableCell(withIdentifier: C.Cell.puppy, for: indexPath) as! PuppyTableViewCell
            cell.bindData(with: puppy)
            return cell
        case .SettingItem(let title, let subTitle):
            let cell: SettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: C.Cell.setting, for: indexPath) as! SettingTableViewCell
            cell.bindData(title: title, subTitle: subTitle)
            return cell
        }
    })
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setSettingViewModelBinding()
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.Segue.settingToEdit,
           let selectedItem = sender as? Puppy,
           let editPuppyVC = segue.destination as? EditPuppyViewController {
            editPuppyVC.puppyInfo = selectedItem
        }
    }
    
    // MARK: - Actions
    @objc
    private func goToEdit() {
        self.performSegue(withIdentifier: C.Segue.settingToEdit, sender: nil)
    }
    
    // MARK: - Methods
    private func setUI() {
        setTableView()
        setCustomBackBtn()
    }
    
    private func setSettingViewModelBinding() {
        settingViewModel = SettingViewModel()
        let input = settingViewModel!.input
        let output = settingViewModel!.output
        
        // INPUT
        rx.viewDidAppear
            .take(1)
            .map { _ in () }
            .bind(to: input.fetchData)
            .disposed(by: bag)
        
        // OUTPUT
        output.isLoading
            .map { !$0 }
            .bind(to: activityIndicatorView.rx.isHidden)
            .disposed(by: bag)

        output.cellData
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        output.errorMessage
            .subscribe(onNext: { [weak self] msg in
                let alertVC = AlertManager.shared.showAlert(title: "λͺ¨λ  λ°λ €κ²¬ μ λ³΄ λ‘λ© μ€ν¨", subTitle: msg, actionBtnTitle: "νμΈ")
                self?.present(alertVC, animated: true, completion: {
                    input.fetchData.onNext(())
                })
            }).disposed(by: bag)
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(SectionItem.self))
            .bind { [weak self] indexPath, item in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                switch item {
                case .PuppyItem(let puppy):
                    self?.performSegue(withIdentifier: C.Segue.settingToEdit, sender: puppy)
                case .SettingItem(_, _):
                    self?.setRecommandCriteria()
                }
            }
            .disposed(by: bag)
    }
    
    /// νμ΄λΈλ·° μ€μ 
    private func setTableView() {
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
        tableView.register(UINib(nibName: "PuppyHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: C.Cell.puppyHeader)
        tableView.register(UINib(nibName: "SettingHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: C.Cell.settingHeader)
    }
    
    private func setRecommandCriteria(){
        let titleFont = [NSAttributedString.Key.font: UIFont(name: "NanumGothic", size: 20)]
        let titleAttrString = NSMutableAttributedString(string: "μ°μ± μΆμ²λ μ€μ ", attributes: titleFont as [NSAttributedString.Key : Any])
        let msgFont = [NSAttributedString.Key.font: UIFont(name: "NanumGothic", size: 17)]
        let msgAttrString = NSMutableAttributedString(string: "λ―ΈμΈλ¨Όμ§λ₯Ό μΆμ² λ°μ κΈ°μ€μ μ νν΄μ£ΌμΈμ!", attributes: msgFont as [NSAttributedString.Key : Any])
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.setValue(titleAttrString, forKey: "attributedTitle")
        actionSheet.setValue(msgAttrString, forKey: "attributedMessage")
        
        let indexPathForSetting = NSIndexPath(row: 0, section: 0) as IndexPath
        let goodAction = UIAlertAction(title: "μ’μ", style: .default) { [weak self] _ in
            UserDefaults.standard.setValue("μ’μ", forKey: "pmRcmdCriteria")
            self?.tableView.reloadRows(at: [indexPathForSetting], with: .fade)
        }
        actionSheet.addAction(goodAction)
        
        let badAction = UIAlertAction(title: "λμ¨", style: .default) { [weak self] _ in
            UserDefaults.standard.setValue("λμ¨", forKey: "pmRcmdCriteria")
            self?.tableView.reloadRows(at: [indexPathForSetting], with: .fade)
        }
        actionSheet.addAction(badAction)
        
        let cancelAction = UIAlertAction(title: "μ·¨μ", style: .cancel)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Setting Section Header View
        if section == 0 {
            let settingHeaderCell = tableView.dequeueReusableCell(withIdentifier: C.Cell.settingHeader) as! SettingHeaderTableViewCell
            settingHeaderCell.bindData(with: "μ€μ ")
            return settingHeaderCell
        }
        // Puppy Section Header View
        else if section == 1 {
            let puppyHeaderCell = tableView.dequeueReusableCell(withIdentifier: C.Cell.puppyHeader) as! PuppyHeaderTableViewCell
            puppyHeaderCell.titleLabel.text = "λ°λ €κ²¬"
            puppyHeaderCell.createButton.addTarget(self, action: #selector(goToEdit), for: .touchUpInside)
            return puppyHeaderCell
        }
        else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
