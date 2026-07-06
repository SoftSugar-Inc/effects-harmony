
import {Rect} from '@softsugar/mars_effects'
/**
 * 目标人物关联结果
 * 存储 faceId 与 bodyId 的映射关系
 */
export class TargetPersonAssociationResult {
  /** faceId 到 bodyId 的映射 */
  faceToBodyMap: Map<number, number> = new Map();
  /** bodyId 到 faceId 的映射 */
  bodyToFaceMap: Map<number, number> = new Map();
}

/**
 * 关联候选对象
 */
class AssociationCandidate {
  /** 优先级：0-强关联，1-弱关联 */
  priority: number;
  faceId: number;
  bodyId: number;
  /** 主评分 */
  primaryScore: number;
  /** 次评分 */
  secondaryScore: number;

  constructor(priority: number, faceId: number, bodyId: number, primaryScore: number, secondaryScore: number) {
    this.priority = priority;
    this.faceId = faceId;
    this.bodyId = bodyId;
    this.primaryScore = primaryScore;
    this.secondaryScore = secondaryScore;
  }

  /**
   * 创建强关联候选
   */
  static strong(faceId: number, bodyId: number, normalizedDistance: number, bodyToFaceAreaRatio: number): AssociationCandidate {
    return new AssociationCandidate(0, faceId, bodyId, normalizedDistance, bodyToFaceAreaRatio);
  }

  /**
   * 创建弱关联候选
   */
  static weak(faceId: number, bodyId: number, overlapRatio: number, normalizedDistance: number): AssociationCandidate {
    return new AssociationCandidate(1, faceId, bodyId, -overlapRatio, normalizedDistance);
  }
}

/**
 * 候选对象比较器
 * 按优先级、主评分、次评分、faceId、bodyId 排序
 */
function compareCandidates(left: AssociationCandidate, right: AssociationCandidate): number {
  if (left.priority !== right.priority) {
    return left.priority - right.priority;
  }
  const primaryCompare = left.primaryScore - right.primaryScore;
  if (primaryCompare !== 0) {
    return primaryCompare;
  }
  const secondaryCompare = left.secondaryScore - right.secondaryScore;
  if (secondaryCompare !== 0) {
    return secondaryCompare;
  }
  const faceCompare = left.faceId - right.faceId;
  if (faceCompare !== 0) {
    return faceCompare;
  }
  return left.bodyId - right.bodyId;
}

/**
 * 基于 face rect / body rect 的几何关系，建立同一人物的 faceId 与 bodyId 映射。
 */
 export default class TargetPersonAssociationHelper {
  /**
   * 构建人脸与人体的关联映射
   * @param faceRectMap 人脸矩形框映射 (faceId -> STRect)
   * @param bodyRectMap 人体矩形框映射 (bodyId -> STRect)
   * @returns 关联结果对象
   */
  static buildAssociations(faceRectMap: Map<number, Rect> | null | undefined,
    bodyRectMap: Map<number, Rect> | null | undefined): TargetPersonAssociationResult {
    const result = new TargetPersonAssociationResult();

    if (!faceRectMap || faceRectMap.size === 0 || !bodyRectMap || bodyRectMap.size === 0) {
      return result;
    }

    const candidates: AssociationCandidate[] = [];

    // 遍历所有 face 和 body 的组合
    faceRectMap.forEach((faceRect, faceId) => {

      const faceArea = TargetPersonAssociationHelper.calculateArea(faceRect);
      const faceCenterX = (faceRect.left + faceRect.right) / 2;
      const faceCenterY = (faceRect.top + faceRect.bottom) / 2;

      bodyRectMap.forEach((bodyRect, bodyId) => {

        const normalizedDistance = TargetPersonAssociationHelper.calculateNormalizedCenterDistance(faceRect, bodyRect);

        // 强关联：人脸中心点在人体框内
        if (TargetPersonAssociationHelper.containsPoint(bodyRect, faceCenterX, faceCenterY)) {
          const bodyToFaceAreaRatio = TargetPersonAssociationHelper.calculateArea(bodyRect) / faceArea;
          candidates.push(AssociationCandidate.strong(faceId, bodyId, normalizedDistance, bodyToFaceAreaRatio));
          return;
        }

        // 弱关联：计算重叠比例
        const overlapRatio = TargetPersonAssociationHelper.calculateOverlapRatio(faceRect, bodyRect);
        if (overlapRatio > 0) {
          candidates.push(AssociationCandidate.weak(faceId, bodyId, overlapRatio, normalizedDistance));
        }
      });
    });

    // 按优先级排序c
    candidates.sort(compareCandidates);

    const usedFaceIds = new Set<number>();
    const usedBodyIds = new Set<number>();

    // 选择最佳匹配
    for (const candidate of candidates) {
      if (usedFaceIds.has(candidate.faceId) || usedBodyIds.has(candidate.bodyId)) {
        continue;
      }
      usedFaceIds.add(candidate.faceId);
      usedBodyIds.add(candidate.bodyId);
      result.faceToBodyMap.set(candidate.faceId, candidate.bodyId);
      result.bodyToFaceMap.set(candidate.bodyId, candidate.faceId);
    }

    return result;
  }


  /**
   * 判断点是否在矩形内
   */
  private static containsPoint(rect: Rect, x: number, y: number): boolean {
    return x >= rect.left && x <= rect.right && y >= rect.top && y <= rect.bottom;
  }

  /**
   * 计算矩形面积
   */
  private static calculateArea(rect: Rect): number {
    const width = rect.right - rect.left;
    const height = rect.bottom - rect.top;
    return Math.max(1, width * height);
  }

  /**
   * 计算归一化的中心点距离
   */
  private static calculateNormalizedCenterDistance(faceRect: Rect, bodyRect: Rect): number {
    const faceCenterX = (faceRect.left + faceRect.right) / 2;
    const faceCenterY = (faceRect.top + faceRect.bottom) / 2;
    const bodyCenterX = (bodyRect.left + bodyRect.right) / 2;
    const bodyCenterY = (bodyRect.top + bodyRect.bottom) / 2;

    const dx = faceCenterX - bodyCenterX;
    const dy = faceCenterY - bodyCenterY;

    const bodyWidth = bodyRect.right - bodyRect.left;
    const bodyHeight = bodyRect.bottom - bodyRect.top;
    const diagonalSquared = Math.max(1, bodyWidth * bodyWidth + bodyHeight * bodyHeight);

    return (dx * dx + dy * dy) / diagonalSquared;
  }

  /**
   * 计算两个矩形的重叠比例（相对于人脸面积）
   */
  private static calculateOverlapRatio(faceRect: Rect, bodyRect: Rect): number {
    // 计算交集
    const left = Math.max(faceRect.left, bodyRect.left);
    const top = Math.max(faceRect.top, bodyRect.top);
    const right = Math.min(faceRect.right, bodyRect.right);
    const bottom = Math.min(faceRect.bottom, bodyRect.bottom);

    if (left >= right || top >= bottom) {
      return 0;
    }

    const intersectionArea = (right - left) * (bottom - top);
    const faceArea = TargetPersonAssociationHelper.calculateArea(faceRect);

    return intersectionArea / faceArea;
  }
}
