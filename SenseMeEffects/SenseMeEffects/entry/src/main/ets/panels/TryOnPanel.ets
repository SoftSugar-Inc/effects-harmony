import { STMaterialManager, TryOnMakeupConfig } from '../models/STMaterialManager'
import { STEffectModel } from '../models/Sticker/STEffectModel'
import { EventBus, EventType } from '../utils/EventBus'
import { MakeUpCell } from './MakeUpCell'
import { common } from '@kit.AbilityKit'
import { STGroupResult } from '../models/Sticker/STGroupResult'
import { promptAction } from '@kit.ArkUI'

// Tab 类型枚举
enum TryOnTabType {
  MAKEUP = 0,
}

// 菜单项数据
class MenuItem {
  config: TryOnMakeupConfig
  groupData: STGroupResult | undefined

  constructor(config: TryOnMakeupConfig, groupData: STGroupResult | undefined) {
    this.config = config
    this.groupData = groupData
  }
}

@Component
export struct TryOnPanel {
  onSnapshotClick?: () => void
  @State currentTab: TryOnTabType = TryOnTabType.MAKEUP
  @State showSubPanel: boolean = false
  @State showPalettePanel: boolean = false
  @State selectedCategoryIndex: number = -1
  @State selectedMaterialIndex: number = -1
  @State menuItems: MenuItem[] = []
  @State currentMaterials: STEffectModel[] = []
  @State selectedColor: string = '#FF6C63'
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  // 预设颜色列表
  private colorList: string[] = [
    '#FF6C63', '#FF8C69', '#FFB6C1', '#FF69B4', '#DB7093',
    '#C71585', '#9370DB', '#8A2BE2', '#9400D3', '#8B008B',
    '#4B0082', '#6A5ACD', '#7B68EE', '#6495ED', '#4169E1',
    '#0000FF', '#0000CD', '#00008B', '#000080', '#191970'
  ]

  aboutToAppear() {
    this.loadMenuData()
  }

  // 加载菜单数据
  private loadMenuData() {
    const manager = STMaterialManager.GetInstance()
    const configs = manager.tryOnMakeupItems()
    const groups = manager.tryOnMakeupGroups()

    this.menuItems = configs.map((config) => {
      const groupData = groups?.get(config.group_id)
      return new MenuItem(config, groupData)
    })
  }

  // 获取图标资源
  private getIconResource(config: TryOnMakeupConfig, isSelected: boolean): Resource {
    const iconName = isSelected ? config.select_icon_press_res_id : config.select_icon_nor_res_id
    return $r(`app.media.${iconName}`)
  }

  // 取消选择
  private onCancelClick() {
    console.info('TryOnPanel: cancel button clicked')
    // 取消当前选中的素材效果
    if (this.selectedCategoryIndex >= 0 && this.selectedMaterialIndex >= 0) {
      const item = this.menuItems[this.selectedCategoryIndex]
      if (item.config) {
        // 发送取消事件
        EventBus.emitEvent(EventType.ReSetOverLapMakeup)
      }
    }
    this.selectedCategoryIndex = -1
    this.selectedMaterialIndex = -1
  }

  // 调色盘按钮点击
  private onPaletteClick() {
    console.info('TryOnPanel: palette button clicked')
    this.showPalettePanel = true
  }

  // 分类图标点击
  private onCategoryClick(index: number) {
    console.info(`TryOnPanel: category ${index} clicked`)
    this.selectedCategoryIndex = index
    const item = this.menuItems[index]
    if (item.groupData && item.groupData.effects) {
      this.currentMaterials = item.groupData.effects
    } else {
      this.currentMaterials = []
    }
    this.showSubPanel = true
  }

  // 素材项点击
  private onMaterialClick(index: number) {
    console.info(`TryOnPanel: material ${index} clicked`)
    this.selectedMaterialIndex = index
    const material = this.currentMaterials[index]
    if (material) {
      // 发送设置素材事件
      EventBus.emitEvent(EventType.SetOverLapMakeup, { data: material })
    }
  }

  // 返回按钮点击
  private onBackClick() {
    console.info('TryOnPanel: back button clicked')
    this.showSubPanel = false
    // 保留 selectedCategoryIndex，这样返回后图标仍然显示选中状态
  }

  // 拍摄按钮点击
  private onTakePhotoClick() {
    this.onSnapshotClick?.()
  }

  // 颜色选择
  private onColorSelect(color: string) {
    this.selectedColor = color
    promptAction.showToast({ message: `已选择颜色: ${color}` })
    // TODO: 调用 libstmobile 设置试妆颜色
  }

  // 关闭调色盘
  private onClosePalette() {
    this.showPalettePanel = false
  }

  build() {
    Stack() {
      Column() {
        // Tab 标题行 - 靠左，黑色字体，选中状态有紫色下划线
        Row() {
          Column() {
            Text('试妆')
              .fontSize(14)
              .fontColor(this.currentTab === TryOnTabType.MAKEUP ? '#333333' : '#999999')
              .fontWeight(this.currentTab === TryOnTabType.MAKEUP ? FontWeight.Medium : FontWeight.Normal)
              .padding({ left: 16, right: 16, top: 12, bottom: 8 })
            // 紫色下划线
            Row()
              .width(24)
              .height(3)
              .backgroundColor(this.currentTab === TryOnTabType.MAKEUP ? '#8B5CF6' : Color.Transparent)
              .borderRadius(1.5)
              .margin({ left: 16 })
          }
          .onClick(() => {
            this.currentTab = TryOnTabType.MAKEUP
          })

          Blank()
        }
        .width('100%')
        .height(48)
        .alignItems(VerticalAlign.Top)

        // 主面板或二级面板
        if (!this.showSubPanel) {
          // 主面板：只显示 JSON 图标列表
          Column() {
            List({ space: 12 }) {
              // JSON 配置中的图标列表
              ForEach(this.menuItems, (item: MenuItem, index: number) => {
                ListItem() {
                  Column() {
                    Image(this.getIconResource(item.config, this.selectedCategoryIndex === index))
                      .width(48)
                      .height(48)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(24)
                      .backgroundColor(this.selectedCategoryIndex === index ? '#FF6C63' : '#33FFFFFF')
                    Text(item.config.des.replace('TryOn', ''))
                      .fontSize(10)
                      .fontColor('#333333')
                      .margin({ top: 4 })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width(64)
                  .height(80)
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => this.onCategoryClick(index))
                }
              })
            }
            .listDirection(Axis.Horizontal)
            .padding({ left: 16, right: 16 })
            .height(100)
            .width('100%')

            // 拍摄按钮（只在主面板显示）
            Row() {
              Blank()
              Column() {
                Image($r('app.media.preview_snapshoot'))
                  .width(48)
                  .height(48)
                  .objectFit(ImageFit.Contain)
              }
              .width(60)
              .height(60)
              .justifyContent(FlexAlign.Center)
              .onClick(() => this.onTakePhotoClick())
              Blank()
            }
            .width('100%')
            .height(70)
            .margin({ top: 10 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Start)
        } else {
          // 二级面板：返回按钮 + 取消按钮 + 调色盘按钮 + 素材列表（同一行）
          Row() {
            // 返回按钮
            Column() {
              Image($r('app.media.ic_back'))
                .width(40)
                .height(40)
                .objectFit(ImageFit.Cover)
                .borderRadius(20)
                .backgroundColor('#33FFFFFF')
              Text('返回')
                .fontSize(10)
                .fontColor('#333333')
                .margin({ top: 4 })
            }
            .width(56)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .onClick(() => this.onBackClick())

            // 取消按钮
            Column() {
              Image($r('app.media.none_process'))
                .width(40)
                .height(40)
                .objectFit(ImageFit.Cover)
                .borderRadius(20)
                .backgroundColor(this.selectedMaterialIndex === -1 ? '#FF6C63' : '#33FFFFFF')
              Text('取消')
                .fontSize(10)
                .fontColor('#333333')
                .margin({ top: 4 })
            }
            .width(56)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .onClick(() => this.onCancelClick())

            // 调色盘按钮
            Column() {
              Image($r('app.media.ic_all_skin'))
                .width(40)
                .height(40)
                .objectFit(ImageFit.Cover)
                .borderRadius(20)
                .backgroundColor('#33FFFFFF')
              Text('调色盘')
                .fontSize(10)
                .fontColor('#333333')
                .margin({ top: 4 })
            }
            .width(56)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .onClick(() => this.onPaletteClick())

            // 素材列表（与按钮同一行）
            List({ space: 8 }) {
              ForEach(this.currentMaterials, (material: STEffectModel, index: number) => {
                ListItem() {
                  MakeUpCell({
                    model: material
                  })
                }
                .onClick(() => this.onMaterialClick(index))
              })
            }
            .listDirection(Axis.Horizontal)
            .layoutWeight(1)
            .height(100)
          }
          .width('100%')
          .height('100%')
          .padding({ left: 8, right: 16 })
        }
      }
      .width('100%')
      .height('100%')

      // 调色盘面板
      if (this.showPalettePanel) {
        Column() {
          Row() {
            Text('选择颜色')
              .fontSize(16)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
            Blank()
            Text('关闭')
              .fontSize(14)
              .fontColor('#8B5CF6')
              .onClick(() => this.onClosePalette())
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })

          // 颜色网格
          Grid() {
            ForEach(this.colorList, (color: string, index: number) => {
              GridItem() {
                Column() {
                  Row()
                    .width(40)
                    .height(40)
                    .backgroundColor(color)
                    .borderRadius(20)
                    .border(this.selectedColor === color ? { width: 3, color: Color.White } : undefined)
                }
                .width(50)
                .height(50)
                .justifyContent(FlexAlign.Center)
                .onClick(() => this.onColorSelect(color))
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
          .rowsGap(10)
          .columnsGap(10)
          .width('100%')
          .height(200)
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .backgroundColor($r('app.color.beauty_panel_color'))
        .opacity(0.95)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .position({ x: 0, y: '100%' })
        .translate({ y: '-100%' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)

  }
}
